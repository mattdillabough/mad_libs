require 'sinatra'
require 'sinatra/content_for'
require 'sqlite3'

PATTERN = /\(:([^)]+)\)/

get '/' do
  db = SQLite3::Database.new 'mad_libs.sqlite'
  @mad_libs = db.execute('SELECT id, title, description, content FROM mad_libs')
  
  erb :index
end

get '/do/:id' do
  db = SQLite3::Database.new 'mad_libs.sqlite'
  @mad_lib_info = db.execute('SELECT id, title, description, content FROM mad_libs WHERE id=?', [params[:id]])
  
  @mad_lib = @mad_lib_info[0][3]
  @pattern_array = []
  
  # TODO: Handle the error case where the supposed "mad lib" doesn't match PATTERN at all.
  @mad_lib.scan(PATTERN) do | match |
    @pattern_array.push($1)
  end
  
  erb :mad_libs
end

post '/do/:id' do
  db = SQLite3::Database.new 'mad_libs.sqlite'
  @mad_lib_info = db.execute('SELECT id, title, description, content FROM mad_libs WHERE id=?', [params[:id]])
  
  # TODO: Handle the error case where there is no mad lib with that ID
  
  input_array = params[:input_array]
  
  check_for_empty_string = 0
  
  input_array.each_with_index do | string |
    if string.length == 0
      check_for_empty_string = check_for_empty_string + 1
    end 
  end
    
  if check_for_empty_string == 0
    @mad_lib_info[0][3] =~ PATTERN
    @output = ''
    @buttonText = 'Return to Homepage'
    @btnLink = '/'
    
    input_array.each_with_index do | match, i |
      # TODO: Handle the error case where the supposed "mad lib" doesn't match PATTERN at all.
      @output += $` + match
      if i == input_array.size - 1
        @output += $'
      else
        $' =~ PATTERN
      end
    end
  else
    @output = 'Sorry you did not fill out all of the patterns'
    @buttonText = 'Fill out patterns'
    @btnLink = '/do/#{@mad_lib_info[0]}'
  end
    
  erb :finished_mad_lib 
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
  redirect '/'
end
