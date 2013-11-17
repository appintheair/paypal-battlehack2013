import json
import webapp2
from models import Donation


class GetActiveDonations(webapp2.RequestHandler):
    def get(self):
        donations = Donation.query(Donation.finished == False).fetch(5000)

        self.response.headers.add_header('Content-Type', 'application/json; encoding=UTF-8')
        self.response.out.write(json.dumps({
            'donations': [donation.to_dict() for donation in donations]
        }))


class GetFinishedDonations(webapp2.RequestHandler):
    def get(self):
        donations = Donation.query(Donation.finished == True).fetch(5000)

        self.response.headers.add_header('Content-Type', 'application/json; encoding=UTF-8')
        self.response.out.write(json.dumps({
            'donations': [donation.to_dict() for donation in donations]
        }))