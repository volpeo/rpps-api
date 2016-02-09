require_relative 'update'
require 'sinatra'

API = {version: "0000", ids:[]}

def update
  API = refresh_ids(API)
  puts "DB refreshed !"
end

get '/' do
  content_type :json
  API.to_json
end

get '/:rpps' do
  content_type :json
  API[:ids].include?(params[:rpps].to_i).to_json
end
