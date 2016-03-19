require 'sinatra/activerecord'

class Pharmacist < ActiveRecord::Base
  self.primary_key = "rpps_id"

  def xyzzy
    return email_address
  end
end
