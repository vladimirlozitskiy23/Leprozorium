#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

get '/' do
	@result = @db.execute 'select * from Posts order by id desc'
	erb :index
end

def init_db
	@db = SQLite3::Database.new 'leprozorium.db'
	@db.results_as_hash = true
end

before do
	init_db
end

configure do
	init_db
	@db.execute 'create table if not exists Posts
	(
		id integer primary key autoincrement,
		created_date date,
		content text
		)'

		@db.execute 'create table if not exists Comments
		(
			id integer primary key autoincrement,
			created_date date,
			content text,
			post_id integer
			)'
end


get '/new' do
	erb :new
end

post '/new' do
  content = params[:content]
	if content.length <= 0
		@error = 'Type text'
		return erb :new
	end
	@db.execute 'insert into Posts(content,created_date) values(?, datetime())',[content]
	redirect to '/'

end


get '/details/:post_id' do
	post_id = params[:post_id]
	results = @db.execute 'select * from Posts where id = ?',[post_id]
	@row = results[0]
	erb :details
end

post '/details/:post_id' do
	post_id = params[:post_id]
	content = params[:content]
	@db.execute 'insert into Comments(post_id,content,created_date) values(?,?, datetime())',[post_id,content]
	redirect to '/details/' + post_id
end
