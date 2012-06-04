module EventChopper

class ScbByDirection < Base
  def searches
    @ss ||= key_value_store 'searches'
  end

  def event_types
    #['search', 'click', 'booking']
    ['search', 'click']
  end

  def map topic, record, stamp
    begin
 
    if topic == 'booking'
      #dt = DateTime.strptime record['booked_at'], '%Y-%m-%dT%H:%M:%SZ'
      #stamp = DateTime.strptime(record['occured_at'], '%Y-%m-%dT%H:%M:%S+04:00').to_time.to_i
      #tk = TimeKey.from_date dt
      #emit({topic => {record['order_number'] => {'state' => record['state'], 'stamp' => stamp}}}, tk)
    elsif topic == 'search' or topic == 'click'
      dt = DateTime.strptime record['created_at'], '%Y-%m-%dT%H:%M:%SZ'
      tk = TimeKey.from_date dt
      searches.put record['id'], record if topic == 'search'
      record = searches.get record['search_id'] if topic == 'click'
      path = record['origin']['iata'] + '-' + record['destination']['iata']
      #emit({path => {topic => 1}}, tk, path)
      emit({path => {(topic == 'search' ? 's' : 'c') => 1}}, tk)
    end

    rescue
      nil
    end
  end

  def reduce data
    t = data.inject({}) do |acc, entry|
      acc.merge(entry) do |k, v1, v2|
        v1.megre(v2) do |k, v1, v2|
          v1 + v2
        end
      end
    end
    puts t
    t
  end
end

end
