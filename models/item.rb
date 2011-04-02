require 'rubygems'
require 'dm-core'
require 'dm-migrations'

class Item
  include DataMapper::Resource
  property :id, Serial, :key => true
  property :name, String, :required => true
  property :text, Text
  property :created_at, DateTime
  property :expires_At, DateTime
  has n, :bids
  has n, :messages
  has n, :bidders, :through => :bids
  belongs_to :user
end

User.auto_migrate! unless User.storage_exists?
