require 'rubygems'
require 'dm-core'
require 'dm-migrations'

class Item
  include DataMapper::Resource
  property :id, Serial, :key => true
  property :name, String, :required => true
  property :start_price, Float, :required => true
  property :text, Text
  property :created_at, Time
  property :expires_at, Time
  has n, :bids
  has n, :messages
  has n, :bidders, 'User', :through => :bids
  belongs_to :user
  
  def current_price
    if bids.count == 0
      start_price
    else
      bids.max(:amount).amount
    end
  end
  
  def expried
    Time.now > expires_at
  end
end
