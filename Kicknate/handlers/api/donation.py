import json
import webapp2
from models import Donation, Donator
import utils


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

        donation = Donation.query(Donation.donation_id == donation_id).get()

        if not donation:
            self.response.out.write(json.dumps({
                'error': 'No such donation'
            }))
            self.abort(404)

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