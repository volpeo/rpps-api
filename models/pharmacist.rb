require 'sinatra/activerecord'

class Pharmacist < ActiveRecord::Base
  self.primary_key = "rpps_id"
end
