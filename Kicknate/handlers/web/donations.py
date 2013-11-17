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
        donation_photo1 = self.request.get('photo1')
        donation_photo2 = self.request.get('photo2')
        donation_photo3 = self.request.get('photo3')
        donation_id = self.request.get('uuid')
        physical_address = self.request.get('physical_address')


        donation = Donation()
        donation.title = donation_title
        donation.amount = 0
        donation.photo1_url = donation_photo1
        donation.photo2_url = donation_photo2
        donation.photo3_url = donation_photo3
        donation.donation_id = donation_id
        donation.physical_address = physical_address
        donation.put()

        time.sleep(0.5)
        self.redirect('/donations')