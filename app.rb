require 'sinatra'
require 'sinatra/content_for'
require 'sqlite3'

get '/' do
  db = SQLite3::Database.new 'mad_libs.sqlite'
  @mad_libs = db.execute('SELECT id, title, description, content FROM mad_libs')
  
  
  erb :index
end

get '/:id' do
  db = SQLite3::Database.new 'mad_libs.sqlite'
  @mad_libs = db.execute('SELECT id, title, description, content FROM mad_libs WHERE id=?', [params[:id]])
  
  erb :mad_libs
end

get '/admin' do
  erb :admin
end

get '/admin/new' do
  erb :new
end

post '/admin/new' do
  db = SQLite3::Database.new 'mad_libs.sqlite'
  db.execute('INSERT INTO mad_libs (title, description, content) VALUES(?, ?, ?)',
    [params[:title], params[:description], params[:content]])
  redirect '/admin'
end
