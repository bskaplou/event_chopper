module EventChopper
  def store name
    #ReductionStore.new EliminatingStore.new RiakStore.new(name)
    EliminatingStore.new TTStore.new(name)
  end


  def key_value_store name 
    TTStore.new(name)
  end

  Dir.new(File.join(File.dirname(__FILE__), '..', 'lib', 'event_chopper', 'reports')).each do |name|
    require "event_chopper/reports/#{name}" if name.end_with? '.rb'
  end

end
