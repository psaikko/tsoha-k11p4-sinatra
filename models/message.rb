require 'rubygems'
require 'dm-core'
require 'dm-migrations'

class Message
  include DataMapper::Resource
  property :id, Serial, :key => true
  property :title, String, :required => true
  property :contents, Text, :required => true
  property :sent_at, DateTime
  belongs_to :sender
  belongs_to :recipient
  belongs_to :item, :required => false
  belongs_to :message, :required => false
  has n, :replies
end

Message.auto_migrate! unless Message.storage_exists?
