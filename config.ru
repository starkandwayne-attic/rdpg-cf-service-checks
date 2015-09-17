require 'sinatra'
require 'json'
require 'pg'

before do
	begin
		json = JSON.parse(ENV['VCAP_SERVICES'])
		@creds ||= json['postgres'].first['credentials']
		@conn ||= PG.connect(@creds['dsn'])
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
	<li><a href="/hi/create">Create the high table if it doesn't exist.</a></li>
	<li><a href="/hi/insert?key=hello&value=folks">insert into the table ?key=hello&value=folks... (change to taste :))</a></li>
	<li><a href="/hi/query">Select from the hi table.</a></li>
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

get '/hi/create' do
	@conn.exec("CREATE SCHEMA IF NOT EXISTS hi;")
	@conn.exec("CREATE TABLE IF NOT EXISTS hi.hi(id SERIAL PRIMARY KEY,key TEXT, value TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);")
	content_type 'application/json'
	JSON.pretty_generate({ :status => 200 })
end

get '/hi/insert' do
	key = params["key"].to_s
	value = params["value"].to_s
	@conn.prepare('hiinsert', 'INSERT INTO hi.hi (key,value) VALUES ($1,$2);')
	res = @conn.exec_prepared('hiinsert', [key,value])
	content_type 'application/json'
	JSON.pretty_generate(res.values)
end

post '/hi/insert' do
	key = params["key"].to_s
	value = params["value"].to_s
	@conn.prepare('hiinsert', 'INSERT INTO hi.hi (key,value) VALUES ($1,$2);')
	res = @conn.exec_prepared('hiinsert', [key,value])
	content_type 'application/json'
	JSON.pretty_generate(res.values)
end

get '/hi/query' do
	res = @conn.exec("SELECT * from hi.hi;")
	content_type 'application/json'
	JSON.pretty_generate(res.values)
end

run Sinatra::Application
