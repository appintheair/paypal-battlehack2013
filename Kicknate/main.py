#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import webapp2
from handlers import api, web
from handlers.handlers import CreateEntitites
from webapp2_extras import jinja2


class MainHandler(webapp2.RequestHandler):
    def get(self):
        self.redirect('/donations', permanent=True)

app = webapp2.WSGIApplication([('/', MainHandler),
                               ('/getDonationDetails', api.GetDonationDetails),
                               ('/createEntities', CreateEntitites),
                               ('/getDonationDonators', api.GetDonationDonators),
                               ('/getActiveDonations', api.GetActiveDonations),
                               ('/getFinishedDonations', api.GetFinishedDonations),
                               ('/donations', web.GetDonationsList),
                               ('/donators', web.GetDonatorsList),
                               ('/createDonation', web.CreateDonation)],
                              debug=True)

jinja2.set_jinja2(jinja2.Jinja2(app, config={}), app=app)
