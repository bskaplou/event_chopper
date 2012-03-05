module EventChopper

class GateSlowness < Base
  def event_types
    ['gate.slowness']
  end

  def reduce data
    data.inject({}) do |acc, entry|
      acc.merge(entry) do |k, v1, v2|
        [v1, v2].max 
      end
    end
  end
end

end
