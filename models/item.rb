require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'dm-aggregates'

class Item
  include DataMapper::Resource
  property :item_id, Serial, :key => true
  property :name, String, :required => true
  property :start_price, Float, :default => 0.0
  property :text, Text
  property :created_at, Time
  property :expires_at, Time
  has n, :bids
  has n, :messages
  belongs_to :user
  
  def current_price
    if bids.count == 0
      start_price
    else
      bids.max(:amount)
    end
  end
  
  def expired
    Time.now > expires_at
  end
  
  def url
    '/items/' + item_id.to_s
  end
end
