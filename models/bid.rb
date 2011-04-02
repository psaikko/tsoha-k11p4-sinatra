require 'rubygems'
require 'dm-core'
require 'dm-migrations'

class Bid
  include DataMapper::Resource
  property :id, Serial, :key => true
  property :amount, Integrer 
  property :made_at, DateTime
  belongs_to :user
  belongs_to :item
end

User.auto_migrate! unless User.storage_exists?
