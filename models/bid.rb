require 'rubygems'
require 'dm-core'
require 'dm-migrations'

class Bid
  include DataMapper::Resource
  property :bid_id, Serial, :key => true
  property :amount, Integer 
  property :made_at, Time
  belongs_to :user
  belongs_to :item
  
  def age_s
    age = Time.now.to_f - made_at.to_f
    if age < 60
      return age.round.to_s + " seconds ago"
    end
    if age < 3600
      return (age / 60.0).round.to_s + " minutes ago"
    end
    if age < 86400
      return (age / 3600.0).round.to_s + " hours ago"
    end
    (age / 86400.0).round.to_s + " days ago"
  end
end
