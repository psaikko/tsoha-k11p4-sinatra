require 'rubygems'
require 'sinatra'
require 'haml'

require 'config/init'

require 'models/bid'
require 'models/item'
require 'models/user'
require 'models/message'

DataMapper.finalize
DataMapper.auto_migrate!

class Tsoha < Sinatra::Base
  enable :sessions

  get '/' do
    if session['id'] != nil
      @name = User.first(:id => session['id']).name
    end
    @items = Item.all
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
    if session['id'] != nil
      haml :listitem
    else
      redirect '/'
    end
  end

  post '/listitem' do
    begin
      @price = Float(params[:price])
    rescue ArgumentError
      @error = "Invalid price"
      haml :listitem
    end
    
    if params[:name] == nil
      @error = "Name unspecified"
      haml :listitem    
    else
      user = User.first(:id => session['id'])
      Item.create(:name => params[:name], :start_price => params[:price], :text => params[:description], :created_at => Time.now, :expires_at => Time.now + 604800, :user => user)
      redirect '/'
    end
  end

  get '/logout' do
    session['id'] = nil
    redirect '/'
  end

end
