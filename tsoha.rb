require 'rubygems'
require 'sinatra'
require 'haml'
require 'rack-flash'

require 'config/init'

require 'models/bid'
require 'models/item'
require 'models/user'
require 'models/message'
require 'lib/helpers'

DataMapper.finalize
DataMapper.auto_upgrade!

class Tsoha < Sinatra::Base
  set :public, File.dirname(__FILE__) + "/public"
  enable :sessions
  use Rack::Flash

  if !User.exists?("admin")
    User.create(:name => "admin", :password => Digest::SHA1.hexdigest("admin"), :admin => true)
  end

  before do
    if session['id']
      @user = User.first(:user_id => session['id'])
    end
  end

  get '/' do
    if flash[:query]
      @query = flash[:query]
      @items = Item.all(:name.like => "%" + flash[:query] + "%", :expires_at.gt => Time.now)
    else
      @query = ""
      @items = Item.all(:expires_at.gt => Time.now)
    end
    
    case flash[:sort]
    when "Item name"
      @items = @items.all(:order => [:name.asc])
    when "Seller"
      @items = @items.all.sort_by{ |item| item.user.name }
    when "Time left"
      @items = @items.all(:order => [:expires_at.desc])
    when "Current price"
      @items = @items.all.sort_by{ |item| item.current_price }
    end
    
    if flash[:reverse] == "reverse"
      @items.reverse!
    end
    
    @users = User.all
    haml :index
  end
  
  post '/' do
    flash[:query] = params[:query]
    flash[:sort] = params[:sort]
    flash[:reverse] = params[:reverse]
    redirect '/'
  end

  get '/login' do
    haml :login
  end

  post '/login' do
    @user = User.authenticate(params[:username], params[:password])
    if @user
      session['id'] = @user.user_id
      redirect '/'
    else
      flash[:error] = "Invalid username or password"
      redirect '/login'
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
    if User.exists?(params[:username])
      flash[:error] = "Username taken"
      redirect '/register'
    else
      if params[:password].length > 0 && params[:password] == params[:password2]
        user = User.register(params[:username], params[:password])
        session['id'] = user.user_id
        flash[:success] = "Registration successful"
        redirect '/'
      else
        flash[:error] = "Passwords do not match or empty"
        redirect '/register'
      end
    end
  end

  get '/user' do
    if @user
      haml :user
    else
      redirect '/'
    end
  end

  get '/listitem' do
    if session['id']
      haml :listitem
    else
      redirect '/'
    end
  end

  post '/listitem' do
    begin
      price = Float(params[:price])
    rescue ArgumentError
      flash[:error] = "Invalid price"
      redirect '/listitem'
    end
    
    if price < 0
      flash[:error] = "Invalid price: " + price.to_s
      redirect '/listitem'
    end
      
    if params[:name] == ""
      flash[:error] = "Item must have a name"
      redirect '/listitem' 
    else
      days = Integer(params[:days])
      hours = Integer(params[:hours])
      minutes = Integer(params[:minutes])
      seconds = minutes * 60 + hours * 3600 + days * 86400;
      
      user = User.first(:user_id => session['id'])
      Item.create(:name => params[:name], :start_price => price, :text => params[:description], :created_at => Time.now, :expires_at => Time.now + seconds, :user => user)
      flash[:success] = "Item created!"
      redirect '/'
    end
  end

  get '/items/:item_id' do
    @item = Item.first(:item_id => Integer(params[:item_id]))
    if @item
      haml :item
    else
      flash[:error] = "Could not find item"
      redirect '/'
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
      @item.user.received_messages << msg
      @item.user.save
      @item.messages << msg
      @item.save
      redirect @item.url
    else
      flash[:error] = "Message must have title and contents"
      redirect @item.url
    end
  end

  post '/items/bid/:item_id' do
    @item = Item.first(:item_id => Integer(params[:item_id]))
    if @user != @item.user
      begin
        price = Float(params[:amount])
      rescue ArgumentError
        flash[:error] = "Invalid bid amount"
        redirect @item.url
      end
      
      if price.nil?
        flash[:error] = "Must specify bid amount"
        redirect @item.url
      end
      
      if price <= @item.current_price
        flash[:error] = "Bid too small"
        redirect @item.url
      else
        user = User.first(:user_id => session['id'])
        bid = Bid.create(:amount => params[:amount], :made_at => Time.now, :user => user, :item => @item)
        @item.bids << bid
        @item.save
        user.bids << bid
        user.save
        flash[:success] = "Bid successful"
        redirect @item.url
      end
    else 
      flash[:error] = "Cannot bid on own item"
      redirect @item.url
    end
  end
end
