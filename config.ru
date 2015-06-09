require 'sinatra'
require 'json'
require 'pg'

Creds = JSON.parse(ENV['VCAP_SERVICES'])['postgresql-db'].first['credentials']

get '/' do
	"<html><body><h1>RDPG CF Service Checks</h1>Simple application to provide checks for rdpg service from a CF app</body></html>"
end

get '/env' do
	{
		:env => ENV.to_h
	}.to_json
end

get '/rdpg' do
	@conn ||= PG.connect( host: Creds['hostname'], port: Creds['port'], dbname: db_name, user: username)
	{
		:node_count => @conn.exec("SELECT count(*) FROM bdr.bdr_nodes;").values.first.first
	}.to_json
end

get '/postgresql/credentials' do
	{
		:credentials => Creds,
	}.to_json
end

run Sinatra::Application
