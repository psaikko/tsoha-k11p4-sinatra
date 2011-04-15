require 'rubygems'
require 'dm-core'
require 'dm-migrations'

class Bid
  include DataMapper::Resource
  property :bid_id, Serial, :key => true
  property :amount, Integer 
  property :made_at, DateTime
  belongs_to :user
  belongs_to :item
end
