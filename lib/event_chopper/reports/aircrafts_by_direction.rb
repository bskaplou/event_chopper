module EventChopper

class AircraftsByDirection < Base
  def event_types
    ['search_result']
  end

  def time_quant
    :hour
  end

  def map topic, record, stamp
    flights = record['tickets'].collect do |t|
      t['direct_flights'] + (t['return_flights'].nil? ? [] : t['return_flights'])
    end
    f = flights.flatten.inject(Hash.new {|h, k| h[k] = []}) do |ac, entry|
      unless entry['aircraft'].nil?
        direction = "#{entry['origin']}-#{entry['destination']}"
        ac[entry['aircraft']] << direction
      end
      ac
    end
    puts f
    emit f unless f.size == 0
  end

  def reduce data
    data.inject({}) do |ac, entry|
      ac.merge(entry) do |acc, a1, a2|
        (a1 + a2).uniq
      end
    end
  end

  def csv data
    tor = ''
    data.each do |k, v|
      line = k
      v.each do |g|
        line += ',' + g
      end
      tor << line + "\n"
    end
    tor
  end

end

end
