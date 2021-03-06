module EventChopper

class Test < Base
  def event_types
    ['search', 'gate_click']
  end

  def map topic, record, stamp
    begin
      emit({topic => 1}) if record['marker'].end_with? '.may_holidays'
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
