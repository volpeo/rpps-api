require_relative 'update'
require 'sinatra'

$api = {version: "0000", data:[]}

def update
  $api = refresh_ids($api)
  puts "DB refreshed !"
  halt 500 if $api[:version] == "0000"
end

get '/' do
  update
  @version = $api[:version]
  erb :index
end

get '/entries' do
  content_type :json
  update
  data = $api[:data]
  data = filtered_data(data, params["column"])
  data = paginated_data(data, params["page"])
  data.to_json
end

get "/entries/all" do
  update
  filtered_data($api[:data], params["column"]).to_json
end

get '/entries/:rpps' do
  content_type :json
  update
  entry = $api[:data].find{ |e| e[:rpps_id] == params[:rpps] }
  if entry.nil?
    halt 404
  else
    entry.to_json
  end
end

def paginated_data(data, page)
  puts "Paginating response."
  if params["page"].nil?
    start = 0
  else
    start = params["page"].to_i*50
  end

  return data[start...start+50] if start < data.length
  []
end

def filtered_data(data, column)
  puts "Filtering response."
  if column.nil? || !data[0].keys.include?(column.to_sym)
    filtered = data.map { |e| e[:rpps_id] }
  else
    filtered = data.map { |e| {rpps_id: e[:rpps_id], (column.to_sym) => e[column.to_sym]} }.compact
  end

  filtered.compact.delete_if { |e| e.values.include?("") }
end
