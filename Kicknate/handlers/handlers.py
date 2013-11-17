import webapp2
from models import Donation, Donator


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



