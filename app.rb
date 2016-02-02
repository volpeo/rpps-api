require_relative 'update'
require 'sinatra'

def update
  @api = refresh_ids
end

update

get '/' do
  @api.to_json
end

get '/:rpps' do
  @api[:ids].include?(params[:rpps]).to_json
end
