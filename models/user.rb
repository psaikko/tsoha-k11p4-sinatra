require 'rubygems'
require 'dm-core'
require 'dm-migrations'

class User
  include DataMapper::Resource
  property :user_id, Serial, :key => true
  property :name, String, :required => true, :unique => true
  property :password, String, :required => true
  property :admin, Boolean, :default => false

  has n, :sent_messages, 'Message'
  has n, :recieved_messages, 'Message'
  has n, :items
  has n, :bids

  def self.exists?(username)
    self.first(:name => username)
  end
  
  def self.authenticate(username, password)
    self.first(:name => username, :password => Digest::SHA1.hexdigest(password))
  end
  
  def self.register(username, password)
    self.create(:name => username, :password => Digest::SHA1.hexdigest(password))
  end
end


