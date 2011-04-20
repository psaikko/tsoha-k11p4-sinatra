require 'rubygems'
require 'dm-core'
require 'dm-migrations'

class Message
  include DataMapper::Resource
  property :message_id, Serial, :key => true
  property :title, String, :required => true
  property :contents, Text, :required => true
  property :sent_at, Time
  belongs_to :sender, 'User'
  belongs_to :recipient, 'User'
  belongs_to :item, :required => false
  belongs_to :message, :required => false
  has n, :replies, 'Message'
  
  def age_s
    age = Time.now.to_f - sent_at.to_f
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



# Message.auto_migrate! unless Message.storage_exists?
