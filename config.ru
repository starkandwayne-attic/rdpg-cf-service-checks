require 'sinatra'
require 'json'
require 'pg'

before do
	@message = ""
	begin
		json = JSON.parse(ENV['VCAP_SERVICES'])
		@creds ||= json['rdpg'].first['credentials']
		@conn ||= PG.connect(@creds['uri'])
		result = @conn.exec("SELECT CURRENT_TIMESTAMP;")
		@node_count = result.values.first.first
	rescue => error
		@node_count = 0
		@message = error # Report the error
	end
end

get '/' do
	"<html><body><h1>RDPG CF Service Checks</h1>Simple application to provide checks for rdpg service from a CF app</body></html>"
end

get '/env' do
	content_type 'application/json'
	{ :env => ENV.to_h }.to_json
end

get '/rdpg' do
	content_type 'application/json'
	{ :node_count => @node_count, :message => @message }.to_json
end

get '/postgresql/credentials' do
	content_type 'application/json'
	{ :credentials => @creds }.to_json
end

run Sinatra::Application
