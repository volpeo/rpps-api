require_relative 'update'
require 'sinatra'

def update
  @api = refresh_ids
end

get '/' do
  @api.to_json
end

get '/:rpps'
  @api[:ids].include? params[:rpps].to_json
end

