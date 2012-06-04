module EventChopper

class ResultsRender < Base
  def event_types
    ['ui_event:proposals_page_ready', 'ui_event:search_start', 'ui_event:search_error']
  end

  def map topic, event, stamp
    begin
      emit({topic.split(':')[1] => 1})
    rescue
      nil
    end
  end

  def reduce data
    t = data.inject({}) do |acc, entry|
      acc.merge(entry) do |k, v1, v2|
        v1 + v2
      end
    end
    t
  end
end

end
