require "event_chopper/version"
require "event_chopper/time_key"
require "event_chopper/base"
require "event_chopper/logger"
require "event_chopper/server"
#require "event_chopper/gate_distribution"
#require "event_chopper/airline_by_direction"
#require "event_chopper/gate_slowness"
#require "event_chopper/search_click_directions"
require "event_chopper/reports/test"
require "event_chopper/store/ttstore"
require "event_chopper/store/riak_store"
require "event_chopper/store/eleminating_store"
require "event_chopper/store/reduction_store"

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

  def store name
    ReductionStore.new(EliminatingStore.new TTStore.new(name))
    #ReductionStore.new EliminatingStore.new RiakStore.new(name)
    #EliminatingStore.new RiakStore.new(name)
  end

  module_function :encode, :decode, :logger, :store
end


