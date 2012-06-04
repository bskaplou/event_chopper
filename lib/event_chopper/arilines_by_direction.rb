module EventChopper

class AirlinesByDirection < Base
  def event_types
    ['search_results']
  end

  def map topic, event, stamp
    begin
      #if event['type'] == 'proposals_page_ready' or event['type'] == 'search_start' or event['type'] == 'search_error'
        #puts "#{event['params_attributes']['origin_iata']} - #{event['params_attributes']['destination_iata']} = #{event['metadata']['count']}"
        puts event
        #emit({event['type'] => 1})
      #end
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
