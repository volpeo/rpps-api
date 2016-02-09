require_relative 'update'
require 'sinatra'

api = {version: "0000", ids:[]}

def update
  api = refresh_ids(api)
  puts "DB refreshed !"
end

get '/' do
  content_type :json
  api.to_json
end

get '/:rpps' do
  content_type :json
  api[:ids].include?(params[:rpps].to_i).to_json
end
