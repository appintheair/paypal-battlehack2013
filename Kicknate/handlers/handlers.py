import webapp2
from models import Donation, Donator


class CreateEntitites(webapp2.RequestHandler):
    def get(self):
        donation = Donation()
        donation.donation_id = "3731A944-09AA-E79E-2E54-0A27DEB925F8"
        donation.amount = 1000
        donation.photo1_url = "http://www.empatika.com/blog/wp-content/uploads/2013/11/pic1_new.jpg"
        donation.photo1_url = "http://www.empatika.com/blog/wp-content/uploads/2013/11/pic2_new.jpg"
        donation.photo1_url = "http://www.empatika.com/blog/wp-content/uploads/2013/11/pic3_new.jpg"
        donation.physical_address = "E9:B4:F3:9E:23:B2"
        donation.title = "Food for Homeless and Homebound"

        donation = donation.put()




