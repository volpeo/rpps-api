require_relative 'update'
require 'sinatra'

api = [{version: "0000"}]

def update(api)
  api[0] = refresh_ids(api[0])
end


get '/' do
  # content_type :json
  update(api)
  p api[0]#.to_json
end

get '/:rpps' do
  content_type :json
  update(api)
  api[0][:ids].include?(params[:rpps].to_i).to_json
end
