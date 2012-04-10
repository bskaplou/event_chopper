module EventChopper

class Scb2 < Base
  def event_types
    ['search', 'click', 'booking']
  end

  def map topic, record, stamp
    puts record.to_s if topic == 'click'
    if topic == 'booking'
      dt = DateTime.strptime record['booked_at'], '%Y-%m-%dT%H:%M:%SZ'
      stamp = DateTime.strptime(record['occured_at'], '%Y-%m-%dT%H:%M:%S%:z').to_time.to_i
      tk = TimeKey.from_date dt
      emit({'total' => {topic => {record['order_number'] => {'state' => record['state'], 'stamp' => stamp}}}}, tk)
      emit({record['gate_id'] => {topic => {record['order_number'] => {'state' => record['state'], 'stamp' => stamp}}}}, tk)
    else
      dt = DateTime.strptime record['occured_at'], '%Y-%m-%dT%H:%M:%S%:z'
      tk = TimeKey.from_date dt
      if topic == 'search'
        emit({ 'total' => {topic => 1}}, tk)
      else
        emit({'total' => {topic => 1}}, tk)
        emit({record['gate_id'] => {topic => 1}}, tk)
      end
    end
  end

  def reduce data
    puts data
    tor = data.inject({}) do |ac, entry|
      ac.merge(entry) do |acc, a1, a2|
        a1.merge(a2) do |k, v1, v2|
          if k.start_with? 'booking'
            v1.merge(v2) do |k, b1, b2|
              b1['stamp'] >= b2['stamp'] ? b1 : b2
            end
          else
            v1 + v2
          end
        end
      end
    end
    puts tor
    tor
  end

  def finalize record
    record.each_key do |key|
      if ! record[key].nil? and record[key].has_key? 'booking'
        record[key]['booking'] = record[key]['booking'].length
      end
    end
    record
  end
end

end
