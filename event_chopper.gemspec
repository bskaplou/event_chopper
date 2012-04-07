# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "event_chopper/version"

Gem::Specification.new do |s|
  s.name        = "event_chopper"
  s.version     = EventChopper::VERSION
  s.authors     = ["ezhikov"]
  s.email       = ["eshikov@mail.ru"]
  s.homepage    = ""
  s.summary     = %q{mr event processing lib}
  s.description = %q{mr event processing lib}

  s.rubyforge_project = "event_chopper"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "tokyotyrant"
  s.add_runtime_dependency "waffle"
  s.add_runtime_dependency "yajl-ruby"
  s.add_runtime_dependency "mongo"
  s.add_runtime_dependency "sinatra"
  s.add_runtime_dependency "riak-client"
  s.add_runtime_dependency "configuratron"
  # s.add_runtime_dependency "rest-client"
end
