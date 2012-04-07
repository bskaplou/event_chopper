require 'mongo'

module EventChopper

class Logger
  include EventChopper

  attr_reader :db

  def initialize host = 'localhost', port = 27017, dbname = 'event_chopper', collection = 'log' 
    @db = Mongo::Connection.new(host, port).db(dbname)[collection]
  end

  def run
    Comm::Consumer.new.subscribe do |topic, message|
      db.insert({:timestamp => DateTime.now.to_time.to_i, :type => topic, :event => encode(message)})
    end
  end

  def replay from, to, types = nil
    query = { '$and' => [
      {:timestamp => {'$lte' => to.to_time.to_i}},
      {:timestamp => {'$gte' => from.to_time.to_i}}
    ]}
    query[:type] = {'$in' => types} unless types.nil?
    db.find(query).each do |arg|
      yield arg['type'], decode(arg['event']), TimeKey.from_date(Time.at(arg['timestamp']))
    end
  end
end

end
