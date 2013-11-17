import time
from random import randint
from string import digits
from handlers.web import base
from models import Donator, Donation


class GetDonationsList(base.BaseHandler):
    def get(self):
        donations = Donation.query(Donation.finished == False).fetch(5000)

        self.render('donations.html', donations=donations)


class GetDonatorsList(base.BaseHandler):
    def get(self):
        donators = Donator.query().fetch(5000)

        self.render('donators.html', donators=donators)


class CreateDonation(base.BaseHandler):
    def get(self):
        self.render('new_donation.html')

    def post(self):
        donation_title = self.request.get('title')
        donation_amount = self.request.get('amount')
        donation_photo1 = self.request.get('photo1')
        donation_photo2 = self.request.get('photo2')
        donation_photo3 = self.request.get('photo3')
        donation_id = ''.join([digits[randint(0, len(digits)-1)] for _ in xrange(7)])

        donation = Donation()
        donation.title = donation_title
        donation.amount = int(donation_amount)
        donation.photo1_url = donation_photo1
        donation.photo2_url = donation_photo2
        donation.photo3_url = donation_photo3
        donation.donation_id = donation_id
        donation.put()

        time.sleep(0.5)
        self.redirect(str(self.request.uri))