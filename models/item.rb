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
      bids.all(:order => [:amount.desc]).first.amount_round
    end
  end
  
  def highest_bidder
    if bids.count > 0
      bids.all(:order => [:amount.desc]).first.user.name
    else
      "No bids"
    end
  end
  
  def time_left_s
    if expired
      "Item expired"
    else
      left = expires_at.to_f - Time.now.to_f
      if left < 60
        return left.round.to_s + " seconds"
      end
      if left < 3600
        return (left / 60.0).round.to_s + " minutes"
      end
      if left < 86400
        return (left / 3600.0).round.to_s + " hours"
      end
      (left / 86400.0).round.to_s + " days"
    end
  end
  
  def expired
    Time.now > expires_at
  end
  
  def url
    '/items/' + item_id.to_s
  end
end
