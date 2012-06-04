module EventChopper

class AirlineByDirection < Base
  def event_types
    ['search_result']
  end

  def map topic, event, stamp
    begin
      unless event['tickets'].nil?
        lines = Hash.new {|h, k| h[k] = []}
        event['tickets'].each do |ticket|
          (ticket['direct_flights'].to_a | ticket['return_flights'].to_a ).each do |flight|
            direction = "#{flight['origin']}-#{flight['destination']}"
            lines[flight['airline']] << direction unless lines[flight['airline']].include? direction 
          end
        end
        lines.each do |k, v|
          emit v, nil, k
        end
      end
    rescue
    end
  end

  def reduce data
    t = data.inject() do |acc, entry|
      (acc + entry).uniq
    end
    puts "-->#{t}"
    t
  end
end

end
