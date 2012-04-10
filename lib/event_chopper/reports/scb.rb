module EventChopper

class Scb < Base
  def event_types
    ['search', 'click', 'booking']
  end

  def time_quant
    :minute
  end

  def map topic, record, stamp
    begin
 
    if topic == 'booking'
      dt = DateTime.strptime record['booked_at'], '%Y-%m-%dT%H:%M:%SZ'
      stamp = DateTime.strptime(record['occured_at'], '%Y-%m-%dT%H:%M:%S+04:00').to_time.to_i
      tk = TimeKey.from_date dt
      emit({topic => {record['order_number'] => {'state' => record['state'], 'stamp' => stamp}}}, tk)
    else
      dt = DateTime.strptime record['created_at'], '%Y-%m-%dT%H:%M:%SZ'
      tk = TimeKey.from_date dt
      emit({topic => 1}, tk)
    end

    rescue
      nil
    end
  end

  def reduce data
    data.inject({}) do |acc, entry|
      acc.merge(entry) do |k, v1, v2|
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

  def finalize record
    if ! record.nil? and record.has_key? 'booking'
      record['paid_booking'] = record['booking'].inject(0) do |acc, k|
        acc + (k[1]['state'] == 'paid' ? 1 : 0)
      end
      record['booking'] = record['booking'].length
    end
    record
  end
end

end
