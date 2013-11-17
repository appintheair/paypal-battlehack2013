
from google.appengine.api import urlfetch
import webapp2, jinja2
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
import os, random
from string import ascii_letters, digits

from google.appengine.api import mail

jinja_environment = jinja2.Environment(
    loader=jinja2.FileSystemLoader(os.path.dirname(__file__)))


class GetDonationsList(webapp2.RequestHandler):

    def get(self):

        donations = Donation.query(Donation.finished==False).fetch(5000)

        template = jinja_environment.get_template('templates/donations.html')
        self.response.out.write(template.render({"donations":donations}))

class GetDonatorsList(webapp2.RequestHandler):

    def get(self):

        donators = Donator.query().fetch(5000)

        template = jinja_environment.get_template('templates/donators.html')
        self.response.out.write(template.render({"donators":donators}))

class CreateDonation(webapp2.RequestHandler):

    def get(self):

        template = jinja_environment.get_template('templates/new_donation.html')
        self.response.out.write(template.render())

    def post(self):
        donation_title = self.request.get('title')
        donation_amount = self.request.get('amount')
        donation_photo1 = self.request.get('photo1')
        donation_photo2 = self.request.get('photo2')
        donation_photo3 = self.request.get('photo3')
        donation_id = ''.join([digits[randint(0, len(digits)-1)] for c in xrange(7)])

        donation = Donation()
        donation.title = donation_title
        donation.amount = int(donation_amount)
        donation.photo1_url = donation_photo1
        donation.photo2_url = donation_photo2
        donation.photo3_url = donation_photo3
        donation.donation_id = donation_id
        donation.put()

        self.response.out.write("Donation created with id: "+str(donation))

