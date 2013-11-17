import datetime
import time
from google.appengine.ext import ndb
from google.appengine.api import memcache
import utils


class Donation(ndb.Model):
    """
    Represents Donation
    """
    donation_id = ndb.StringProperty(required=True)
    date_added = ndb.DateTimeProperty(auto_now_add=True)
    title = ndb.StringProperty(required=True)
    amount = ndb.IntegerProperty(required=True)
    numberOfVoters = ndb.IntegerProperty(default=0)
    amountRaised = ndb.IntegerProperty(default=0)
    photo1_url = ndb.StringProperty(required=True)
    photo2_url = ndb.StringProperty()
    photo3_url = ndb.StringProperty()
    finished = ndb.BooleanProperty(default=False)
    is_kickstarter_type = ndb.BooleanProperty(default=False)



    def to_dict(self):
        response = super(Donation, self).to_dict()
        response['date_added'] = utils.to_int(response['date_added'])
        return response

class Donator(ndb.Model):
    email = ndb.StringProperty(required=True)
    amountDonated = ndb.IntegerProperty(required=True)
    date_donated = ndb.DateTimeProperty(auto_now_add=True)
    donation = ndb.KeyProperty(kind=Donation, required=True)

    def to_dict(self):
        response = super(Donator, self).to_dict(exclude=['donation'])
        response['date_donated'] = utils.to_int(response['date_donated'])
        return response