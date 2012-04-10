module EventChopper

class GateResponses < Base
  def event_types
    ['search_result']
  end

  def map topic, record, stamp
    stamp = DateTime.strptime(record['occured_at'], '%Y-%m-%dT%H:%M:%S%:z')
    tk = TimeKey.from_date stamp, :half_minute
    to_emit = {}
    record['metadata']['gates_meta'].each do |h|
      to_emit[h['label']] = {'requests' => 1 , 'duration' => h['duration'], 'tickets' => h['count'].nil? ? 0 : h['count'], 'errors' => h['count'].nil? ? 1 : 0}
    end
    emit to_emit, tk
  end

  def reduce data
    tor = data.inject({}) do |ac, entry|
      ac.merge(entry) do |acc, a1, a2|
        a1.merge(a2) do |k, v1, v2|
          v1 + v2
        end
      end
    end
    tor    
  end
end

end
