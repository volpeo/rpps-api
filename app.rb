require_relative 'update'
require 'sinatra'

def update
  @api = refresh_ids
end

get '/' do
  @api
end

get '/:rpps' do
  @api[:ids].include?(params[:rpps]).to_json
end
