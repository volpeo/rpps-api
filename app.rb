require_relative 'update'
require 'sinatra'

API = [{version: "0000"}]

def update(api)
  API[0] = refresh_ids(API[0])
end

get '/' do
  content_type :json
  update(API)
  API[0].to_json
end

get '/:rpps' do
  content_type :json
  update(API)
  API[0][:ids].include?(params[:rpps].to_i).to_json
end
