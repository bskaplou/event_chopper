require "event_chopper/version"
require "event_chopper/time_key"
require "event_chopper/base"
require "event_chopper/logger"
require "event_chopper/server"
require "event_chopper/store/ttstore"
require "event_chopper/store/riak_store"
require "event_chopper/store/eleminating_store"
require "event_chopper/store/reduction_store"
require File.join(File.dirname(__FILE__), '..', 'config/config.rb')

module EventChopper
  def encode data
    Yajl::Encoder.encode data
  end

  def decode data
    Yajl::Parser.parse data
  end

  module_function :encode, :decode, :store, :key_value_store
end

