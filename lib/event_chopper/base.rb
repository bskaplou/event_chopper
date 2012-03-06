require 'comm'
require 'bunny'

module EventChopper

NOID = ''

class Base
  def initialize name = self.class.name
    @store = EliminatingStore.new TTStore.new(name)
  end

  def emit record, id = NOID, stamp = nil 
    stamp = TimeKey.now if stamp.nil?
    current_value = get stamp, id
    if current_value.nil?
      current_value = record
    else
      current_value = reduce [current_value, record]
    end
    @store.put stamp, current_value, id
    puts stamp.to_s + ' -> ' + id + ' -> ' + current_value.to_s
  end

  def map topic, record, stamp = nil
    emit record, NOID, stamp
  end

  def get stamp, id = NOID
    tor = @store.get stamp, id
    if tor.nil?
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

  def run
    Comm::Consumer.new(event_types).subscribe do |topic, message|
      map topic, message
    end
  end
end

end
