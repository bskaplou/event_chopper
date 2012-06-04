module EventChopper

class ClickPosition < Base
  def event_types
    ['ui_event:purchased_proposal']
  end

  def map topic, record, stamp
    begin
      emit({record['data']['index'].to_s => 1})
    rescue
      nil
    end
  end

  def reduce data
    tor = data.inject({}) do |acc, entry|
      acc.merge(entry) do |k, v1, v2|
        v1 + v2
      end
    end
    puts tor
    tor
  end
end

end
