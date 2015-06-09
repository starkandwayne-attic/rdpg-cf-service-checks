require 'sinatra'
require 'json'
require 'pg'

before do
	begin
		json = JSON.parse(ENV['VCAP_SERVICES'])
		@creds ||= json['rdpg'].first['credentials']
		@conn ||= PG.connect(@creds['uri'])
		result = @conn.exec("SELECT CURRENT_TIMESTAMP;")
		@message = result.values.first.first
	rescue => error
		@message = error # Report the error
	end
end

get '/' do
	return <<HTML
	<html><body><h1>RDPG CF Service Checks</h1>
	Simple application to provide checks for rdpg service from a CF app
	<ul>
	<li><a href="/env">Application Environment</a></li>
	<li><a href="/rdpg">Database Timestamp Check</a></li>
	<li><a href="/postgresql/credentials">VCAP_SERVICES rdpg Credentials Check</a></li>
	</ul>
	</body></html>
HTML
end

get '/env' do
	content_type 'application/json'
	JSON.pretty_generate({ :env => ENV.to_h })
end

get '/rdpg' do
	content_type 'application/json'
	JSON.pretty_generate({ :message => @message })
end

get '/postgresql/credentials' do
	content_type 'application/json'
	JSON.pretty_generate({ :credentials => @creds })
end

run Sinatra::Application
