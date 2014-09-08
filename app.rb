require 'sinatra'
require 'sinatra/content_for'

get '/' do
  erb :index
end