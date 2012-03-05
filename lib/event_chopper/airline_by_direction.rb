module EventChopper

class AirlineByDirection < Base
  def event_types
    ['airline.by.direction']
  end

  def reduce data
    data.inject({}) do |acc, entry|
      acc.merge(entry) {|k, v1, v2| (v1 + v2).uniq}
    end
  end
end

end
