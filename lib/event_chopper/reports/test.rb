module EventChopper

class Test < Base
  def event_types
    ['search', 'click']
  end

  def map topic, record, stamp
    emit({topic => 1}) if record['marker'].end_with? '.may_holidays'
  end

  def reduce data
    t = data.inject({}) do |acc, entry|
      acc.merge(entry) do |k, v1, v2|
        v1 + v2
      end
    end
    puts "REDUCE" + t.to_s
    t
  end
end

end
