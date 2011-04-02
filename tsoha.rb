require 'rubygems'
require 'sinatra'
require 'haml'
require 'config/init'

require 'models/user'

class Tsoha < Sinatra::Base

  enable :sessions
  set :public, File.dirname(__FILE__) + "/public"

  get '/' do
    @esimerkkimuuttuja = "tämä on muuttuja"
    @sessiosta_muuttujaan = session[:muuttuja]
    @testmodelin_arvot = User.all
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
