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
  set :public, File.dirname(__FILE__) + "/public"
  enable :sessions

  if !User.exists("admin")
    User.create(:name => "admin", :password => "admin", :admin => true)
  end

  before do
    if session['id'] != nil
      @user = User.first(:user_id => session['id'])
    end
  end

  get '/' do
    @items = Item.all(:order => [:expires_at.asc])
    @users = User.all
    haml :index
  end

  get '/login' do
    haml :login
  end

  post '/login' do
    @user = User.first(:name => params[:username], :password => params[:password])
    if @user != nil
      session['id'] = @user.user_id
      redirect '/'
    else
      @msg = "Invalid username or password"
      haml :login
    end
  end

  get '/logout' do
    session['id'] = nil
    redirect '/'
  end

  get '/register' do
    haml :register
  end

  post '/register' do
    if User.exists(params[:username])
      @msg = "Username taken"
      haml :register
    else
      if params[:password] == params[:password2]
        user = User.create(:name => params[:username], :password => params[:password])
        session['id'] = user.user_id
        redirect '/'
      else
        @msg = "Passwords do not match"
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
      @msg = "Invalid price"
      haml :listitem
    end
    
    if params[:name] == nil
      @msg = "Name unspecified"
      haml :listitem    
    else
      user = User.first(:user_id => session['id'])
      Item.create(:name => params[:name], :start_price => params[:price], :text => params[:description], :created_at => Time.now, :expires_at => Time.now + 604800, :user => user)
      redirect '/'
    end
  end

  get '/items/:item_id' do
    @item = Item.first(:item_id => Integer(params[:item_id]))
    if @item == nil
      @msg = "Item not found"
      haml :index
    else    
      haml :item
    end
  end

  get '/items/delete/:item_id' do
    del_item = Item.first(:item_id => Integer(params[:item_id]))
    del_item.destroy
    redirect '/'
  end

  post '/items/msg/:item_id' do
    @item = Item.first(:item_id => Integer(params[:item_id]))
    title = params[:title]
    contents = params[:contents]
    if !(title == "" || contents == "")
      msg = Message.create(:title => title, :contents => contents, :sent_at => Time.now, :sender => @user, :recipient => @item.user, :item => @item)
      @user.sent_messages << msg
      @user.save
      @item.user.recieved_messages << msg
      @item.user.save
      @item.messages << msg
      @item.save
      haml :item
    else
      @msg = "Error leaving message"
      haml :item
    end
  end

  post '/items/bid/:item_id' do
    @item = Item.first(:item_id => Integer(params[:item_id]))
    begin
      price = Float(params[:amount])
    rescue ArgumentError
      @msg = "Invalid bid amount"
      haml :item
    end
    
    if price == nil
      @msg = "Must specify a price"
      haml :item
    end
    
    if price != nil && price <= @item.current_price
      @msg = "Bid too small"
      haml :item
    else
      user = User.first(:user_id => session['id'])
      bid = Bid.create(:amount => price, :made_at => Time.now, :user => user, :item => @item)
      @item.bids << bid
      @item.save
      user.bids << bid
      user.save
      @msg = "Bid successful!"
      haml :item
    end   
  end
end
