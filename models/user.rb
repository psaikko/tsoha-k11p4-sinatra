require 'rubygems'
require 'dm-core'
require 'dm-migrations'

class User
  include DataMapper::Resource
  property :id, Serial, :key => true
  property :name, String, :required => true, :unique => true
  property :password, String, :required => true
  property :admin, Boolean, :default => false

  has n, :sent_messages
  has n, :recieved_messages
  has n, :items
  has n, :bids
end

User.auto_migrate! unless User.storage_exists?
