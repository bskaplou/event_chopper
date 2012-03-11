module EventChopper

class SearchClickDirections < Base
  def event_types
    ['search', 'click']
  end

  def map topic, record, stamp = nil
    emit({record['origin'] + '-' + record['destination'] => {topic => 1}}, TimeKey.from_date(DateTime.parse(record['created_at'])))
  end 

  def reduce data
    data.inject({}) do |acc, entry|
      acc.merge(entry) do |k, v1, v2|
        v1.merge(v2) do |a, b, c|
          b + c
        end
      end
    end
  end
end

end
