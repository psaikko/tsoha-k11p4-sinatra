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
end

# Message.auto_migrate! unless Message.storage_exists?
