require 'sinatra'
require 'json'
require 'pg'

def conn
	$conn ||= PG.connect( host: creds['hostname'], port: creds['port'], dbname: db_name, user: username)
end

def creds
	$creds ||= JSON.parse(ENV['VCAP_SERVICES'])['postgresql-db'].first['credentials']
end

get '/' do
	"<html><body><h1>RDPG CF Service Checks</h1>Simple application to provide checks for rdpg service from a CF app</body></html>"
end

get '/env' do
	{ :env => ENV.to_h }.to_json
end

get '/rdpg' do
	node_count = conn.exec("SELECT count(*) FROM bdr.bdr_nodes;").values.first.first
	{ :node_count => node_count }.to_json
end

get '/postgresql/credentials' do
	{ :credentials => creds }.to_json
end

run Sinatra::Application
