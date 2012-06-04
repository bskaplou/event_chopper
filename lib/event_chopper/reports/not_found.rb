module EventChopper

class NotFound < Base
  def event_types
    ['search_result']
  end

  def map topic, record, stamp
    begin
      dir = record['params_attributes']['origin_iata'] + '-' + record['params_attributes']['destination_iata']
      emit ({dir => 1}) if record['tickets'].size == 0
    rescue
      nil
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
