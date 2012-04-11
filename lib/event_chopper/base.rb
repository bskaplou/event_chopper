require 'waffle'
require 'bunny'

module EventChopper

NOID = ''

class Base
  include EventChopper

  def initialize name = self.class.name
    @store = store name
  end

  def time_quant
    :ten_minutes
  end

  def emit record, stamp = nil, id = NOID
    stamp = TimeKey.now if stamp.nil?
    current_value = get stamp, id
    if current_value.nil?
      current_value = record
    else
      current_value = reduce [current_value, record]
    end
    @store.put stamp, current_value, id
  end

  def map topic, record, stamp = nil
    emit record, stamp, NOID
  end

  def finalize record
    record
  end

  def get stamp, id = NOID
    tor = @store.get stamp, id
    if tor.nil? and time_quant != stamp.type
      chunks = stamp.children.inject([]) do |acc, item|
        t = get item, id
        acc << t unless t.nil?
        acc
      end
      if chunks.size > 0
        tor = reduce chunks
        @store.put stamp, tor, id
      end
    end
    tor
  end

  def fetch stamp, id = NOID
    to_fin = get(stamp, id)
    finalize to_fin unless to_fin.nil?
  end

  def run
      transport = Waffle::Base.new eval("Waffle::Transports::#{Waffle::Config.transport.capitalize}").new

      transport.subscribe event_types do |topic, event|
        map topic, event, TimeKey.now
      end
  end

end
end
