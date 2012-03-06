require "event_chopper/version"
require "event_chopper/time_key"
require "event_chopper/base"
require "event_chopper/logger"
require "event_chopper/gate_distribution"
require "event_chopper/airline_by_direction"
require "event_chopper/gate_slowness"
require "event_chopper/store/ttstore"
require "event_chopper/store/eleminating_store"

module EventChopper
  def encode data
    Yajl::Encoder.encode data
  end

  def decode data
    Yajl::Parser.parse data
  end

  def logger
    @logger ||= Logger.new
  end

  module_function :encode, :decode, :logger
end


