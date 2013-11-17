import json
import webapp2
from models import Donation, Donator
import utils
import json
import logging
import webapp2
import urllib
import urlparse
from google.appengine.api import urlfetch

def _validate_receipt(receipt):
    api_username = 'q.pronin-facilitator_api1.gmail.com'
    api_password = 'PCRDAWCS9NP4TA2T'
    signature = 'AQU0e5vuZCvSg-XJploSa.sGUDlpAAteHWbtoNsap6FPnIvfRCTc7TbY'

    #logging.info(str(receipt))

    result = urlfetch.fetch('https://svcs.sandbox.paypal.com/AdaptivePayments/PaymentDetails',
                            method=urlfetch.POST,
                            validate_certificate=False,
                            payload=urllib.urlencode({
                                'payKey': receipt['proof_of_payment']['adaptive_payment']['pay_key'],
                                'requestEnvelope.errorLanguage': 'en_US'
                            }),
                            headers={
                                'X-PAYPAL-SECURITY-USERID': api_username,
                                'X-PAYPAL-SECURITY-PASSWORD': api_password,
                                'X-PAYPAL-SECURITY-SIGNATURE': signature,
                                'X-PAYPAL-REQUEST-DATA-FORMAT': 'NV',
                                'X-PAYPAL-RESPONSE-DATA-FORMAT': 'NV',
                                'X-PAYPAL-APPLICATION-ID': receipt['proof_of_payment']['adaptive_payment']['app_id']
                            })

    obj = urlparse.parse_qs(result.content)
    success = True
    success &= 'status' in obj and obj['status'][0] == 'COMPLETED'
    success &= 'currencyCode' in obj and obj['currencyCode'][0] == receipt['payment']['currency_code']
    return success

class GetDonationDetails(webapp2.RequestHandler):
    def get(self):
        self.response.headers['Content-type'] = 'application/json'

        donation_id = self.request.get('donation_id')

        if not donation_id:
            self.response.out.write(json.dumps({
                'error': 'Please supply donation id'
            }))
            self.abort(400)

        donation = Donation.query(Donation.donation_id == donation_id).get()
        if not donation:
            self.response.out.write(json.dumps({
                'error': 'No such donation :('
            }))
            self.abort(404)

        self.response.out.write(json.dumps(donation.to_dict()))




    def post(self):
        self.response.headers['Content-type'] = 'application/json'

        donation_id = self.request.get('donation_id')
        amount = int(self.request.get('amount'))
        email = self.request.get('donator_email')
        receipt = self.request.get('receipt')



        donation = Donation.query(Donation.donation_id == donation_id).get()

        if not donation:
            self.response.out.write(json.dumps({
                'error': 'No such donation'
            }))
            self.abort(404)

        receipt = json.loads(receipt)
        validation = _validate_receipt(receipt)
        if not validation:
            self.response.out.write(json.dumps({
                'error': 'Not Valid'
            }))
            self.response.set_status(400)
            return


        donation.numberOfVoters += 1
        if donation.amountRaised:
            donation.amountRaised += amount
        else:
            donation.amountRaised = amount

        donation.put()

        donator = Donator()
        donator.email = email
        donator.amountDonated = amount
        donator.donation = donation.key
        donator.put()

        if donation.amountRaised >= donation.amount and donation.finished is False:
            donation.finished = True
            donation.put()

            donators = Donator.query(Donator.donation == donation.key).fetch(5000)

            for donator in donators:
                if donator.email:
                    utils.send_email(donation, donator)

        self.response.out.write(json.dumps({
            'donation': donation.to_dict()
        }))


class GetDonationDonators(webapp2.RequestHandler):
    def get(self):
        self.response.headers['Content-type'] = 'application/json'

        donation_id = self.request.get('donation_id')

        if not donation_id:
            self.response.out.write(json.dumps({
                'error': 'Please supply donation id'
            }))
            self.abort(400)

        donation = Donation.query(Donation.donation_id == donation_id).get()
        if not donation:
            self.response.out.write(json.dumps({
                'error': 'No such donation :('
            }))
            self.abort(404)

        donators = Donator.query(Donator.donation == donation.key).fetch(5000)

        self.response.headers.add_header('Content-Type', 'application/json; encoding=UTF-8')
        self.response.out.write(json.dumps({
            'donators': [donator.to_dict() for donator in donators]
        }))