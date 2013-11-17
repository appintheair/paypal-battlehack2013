from google.appengine.api import urlfetch
import webapp2
import json, logging
from random import randint
import urllib, logging
from models import Donation, Donator
from math import radians, cos, sin, asin, sqrt
import datetime
from google.appengine.ext import ndb
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from google.appengine.api import mail


class GetDonationDetails(webapp2.RequestHandler):

    def get(self):
        self.response.headers['Content-type'] = 'application/json'
        donationid_param = "1"
        try:
            donationid_param = self.request.get('donation_id')
        except:
            self.response.out.write("Please supply donation id")
            return
        donation =  Donation.query(Donation.donation_id == donationid_param).get()

        if donation:
            obj = donation.to_dict()
            self.response.out.write(json.dumps(obj))


    def sendEmail(self, donation, donator):
        # Your From email address
        fromEmail = "bayram.annakov@gmail.com"

        # Create message container - the correct MIME type is multipart/alternative.
        msg = MIMEMultipart('alternative')
        msg['Subject'] = "Donation raised successfully"
        msg['From'] = fromEmail
        msg['To'] = donator.email

        text = "Donation '"+str(donation.title)+"' was raised successfully! \nThank you sooo much!\n"

        # Login credentials
        username = 'bayramannakov'
        password = ",fqrf13@fgcd"

        # Record the MIME types of both parts - text/plain and text/html.
        part1 = MIMEText(text, 'plain')
        msg.attach(part1)

        # Open a connection to the SendGrid mail server
        s = smtplib.SMTP('smtp.sendgrid.net', 587)

        # Authenticate
        s.login(username, password)

        # sendmail function takes 3 arguments: sender's address, recipient's address
        # and message to send - here it is sent as one string.
        s.sendmail(fromEmail, donator.email, msg.as_string())

        s.quit()

    def post(self):
        self.response.headers['Content-type'] = 'application/json'
        logging.info("Donation id:  "+str(self.request.get('donation_id'))+" ; amount: "+str(self.request.get('amount')))

        donationid_param = self.request.get('donation_id')
        amount_param = int(self.request.get('amount'))
        donator_email = self.request.get('donator_email')


        donation = Donation.query(Donation.donation_id == donationid_param).get()

        if donation:
            donation.numberOfVoters += 1
            if donation.amountRaised:
                donation.amountRaised += amount_param
            else:
                donation.amountRaised = amount_param

            donation.put()

            donator = Donator()
            donator.email = donator_email
            donator.amountDonated = amount_param
            donator.donation = donation.key
            donator.put()

            if donation.amountRaised >= donation.amount and donation.finished == False:
                donators =  Donator.query(Donator.donation == donation.key).fetch(5000)

                donation.finished = True
                for donator in donators:
                    if donator.email: self.sendEmail(donation,donator)



            self.response.out.write(json.dumps({'donation': donation.to_dict()}))


class GetDonationDonators(webapp2.RequestHandler):

    def get(self):
        self.response.headers['Content-type'] = 'application/json'
        donationid_param = "1"
        try:
            donationid_param = self.request.get('donation_id')
        except:
            self.response.out.write("Please supply donation id")
            return

        donation = Donation.query(Donation.donation_id == donationid_param).get()

        donators =  Donator.query(Donator.donation == donation.key).fetch(5000)

        if donators:
            response = [donator.to_dict() for donator in donators]

            self.response.headers.add_header('Content-Type', 'application/json; encoding=UTF-8')
            self.response.out.write(json.dumps({'donators': response}))

class CreateEntitites(webapp2.RequestHandler):

    def get(self):
        donation = Donation()
        donation.donation_id = "1"
        donation.amount = 1000
        donation.photo1_url = "http://empatika.com/img/logo.jpg"
        donation.title = "Donation"

        donation = donation.put()

        donator = Donator()
        donator.amountDonated = 10
        donator.donation = donation.key
        donator.email = "bayram.annakov@gmail.com"
        donator.put()



