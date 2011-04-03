require 'rubygems'
require 'sinatra'
require 'erb'
require 'haml'

require 'config/init'

require 'models/bid'
require 'models/item'
require 'models/user'
require 'models/message'

class Tsoha < Sinatra::Base
  get '/' do
    # haml :index
  end

  get '/login' do
    # haml :login
  end

  get '/register' do
    # haml :register
  end
end
