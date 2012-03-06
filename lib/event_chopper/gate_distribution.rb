module EventChopper

class GateDistribution < Base
  def event_types
    ['gate.distribution.first']
  end

  def map topic, message, stamp
    message.keys.each do |key|
      emit message[key], key, stamp
    end
  end

  def reduce data
    data.inject({}) do |acc, entry|
      acc.merge(entry) do |k, v1, v2|
        v1 + v2 
      end
    end
  end
end

end
