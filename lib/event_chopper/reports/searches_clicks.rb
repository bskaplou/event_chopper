module EventChopper

class SearchesClicks < Base
  def event_types
    ['search', 'click']
  end

  def time_quant
    :minute
  end

  def map topic, record, stamp
    begin
      emit({topic => 1})
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
