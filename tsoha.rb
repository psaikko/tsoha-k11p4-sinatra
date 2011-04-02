require 'rubygems'
require 'sinatra'
require 'haml'
require 'config/init'


class Tsoha < Sinatra::Base

  enable :sessions
  set :public, File.dirname(__FILE__) + "/public"

  get '/' do
    "Testing"
    haml :index
  end

  get '/login' do
    haml :login
  end

  get '/register' do
    haml :register
  end

  get '/sessioon/:arvo' do
    session[:muuttuja] = params[:arvo]
    redirect '/'
  end

end
