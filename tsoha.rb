require 'rubygems'
require 'sinatra'
require 'haml'

require 'config/init'

require 'models/bid'
require 'models/item'
require 'models/user'
require 'models/message'

DataMapper.finalize
DataMapper.auto_upgrade!

class Tsoha < Sinatra::Base
  enable :sessions

  get '/' do
    if session['id'] != nil
      @name = User.first(:id => session['id']).name
    end
    @users = User.all
    haml :index
  end

  get '/login' do
    haml :login
  end

  post '/login' do
    @user = User.first(:name => params[:username], :password => params[:password])
    if @user != nil
      session['id'] = @user.id
      redirect '/'
    else
      @error = "Invalid username or password"
      haml :login
    end
  end

  get '/register' do
    haml :register
  end

  post '/register' do
    if User.exists(params[:username])
      @error = "Username taken"
      haml :register
    else
      if params[:password] == params[:password2]
        @user = User.create(:name => params[:username], :password => params[:password])
        session['id'] = @user.id
        redirect '/'
      else
        @error = "Passwords do not match"
        haml :register
      end
    end
  end

  get '/listitem' do
    haml :listitem
  end

  post '/listitem' do
    redirect '/'
  end

end
