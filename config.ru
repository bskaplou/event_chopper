$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'event_chopper'

run EventChopper::Server
