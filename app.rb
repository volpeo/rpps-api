require_relative 'update'
require 'sinatra'

Api = {version: "0000", ids:[]}

def update
  Api = refresh_ids(Api)
  puts "DB refreshed !"
end

get '/' do
  content_type :json
  Api.to_json
end

get '/:rpps' do
  content_type :json
  Api[:ids].include?(params[:rpps].to_i).to_json
end
