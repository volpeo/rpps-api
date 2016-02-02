require_relative 'update'
require 'sinatra'
require 'sinatra/reloader'

api = ["test"]

def update(api)
  api[0] = refresh_ids
end

update(api)

get '/' do
  content_type :json
  api[0].to_json
end

get '/:rpps' do
  content_type :json
  api[0][:ids].include?(params[:rpps].to_i).to_json
end
