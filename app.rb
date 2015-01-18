require 'sinatra'
require 'sinatra/content_for'
require 'sqlite3'

PATTERN = /\(:([^)]*)\)/
         #/\(:([^|]+)\|?([^)]*)\)/
         #/\(:([^)]*)\)/ ----> original

def get_madlib_by_id(id)
  db = SQLite3::Database.new 'mad_libs.sqlite'
  mad_libs = db.execute('SELECT id, title, description, content FROM mad_libs WHERE id=?', [id])
  # TODO: Handle the error case where there is no mad lib with that id.
  mad_lib = mad_libs[0]
  content = mad_lib[3]
  pattern_array = []
  
  # TODO: Handle the error case where the supposed "mad lib" doesn't match PATTERN at all.
  content.scan(PATTERN) do | match |
    pattern_array.push($1)  # $2 is the default value.
  end
  mad_lib << pattern_array  # Now mad_lib[4] is the pattern array
end

get '/' do
  db = SQLite3::Database.new 'mad_libs.sqlite'
  @mad_libs = db.execute('SELECT id, title, description, content FROM mad_libs')
  
  erb :index
end

get '/do/:id' do
  @mad_lib = get_madlib_by_id(params[:id])
  erb :mad_libs
end

post '/do/:id' do
  @mad_lib = get_madlib_by_id(params[:id])
  
  # TODO: Handle the error case where there is no mad lib with that ID
    
  @input_array = params[:input_array]
  empty_input = @input_array.detect do |input|
    input.empty?
  end
  
  if empty_input
    @error = "Please fill out all fields."
    return erb :mad_libs
  else
    @mad_lib[3] =~ PATTERN
    @output = ''
    
    @input_array.each_with_index do | match, i |
      # TODO: Handle the error case where the supposed "mad lib" doesn't match PATTERN at all.
      @output += $` + match
      if i == @input_array.size - 1
        @output += $'
      else
        $' =~ PATTERN
      end
    end
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
  @title = params[:title]
  @description = params[:description]
  @content = params[:content]
  
  if @title.empty? || @description.empty? || @content.empty?
    @error = "Please fill out all fields."
    return erb :new
  else
    db = SQLite3::Database.new 'mad_libs.sqlite'
    db.execute('INSERT INTO mad_libs (title, description, content) VALUES(?, ?, ?)',
              [params[:title], params[:description], params[:content]])
    redirect '/'
  end
end

