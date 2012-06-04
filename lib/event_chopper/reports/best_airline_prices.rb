module EventChopper

class BestAirlinePrices < Base
  def event_types
    ['search_result']
  end

  def rates
    {"uah" => 3.66, "usd" => 29.38, "eur" => 38.77, "rub" => 1}
  end

  def normalize gates, rates, prices
    prices.keys.collect do |gate_id|
      gate = gates[gates.index {|g| g['id'].to_s == gate_id.to_s}]
      {'id' => gate_id ,'name' => gate['label'], 'price' => prices[gate_id] * rates[gate['currency_code']]}
    end
  end

  def plotting_carrier ticket
    if ticket.has_key? 'main_airline'
      ticket['main_airline']
    else
      return_flights = (ticket.has_key? 'return_flights') ? ticket['return_flights'] : []
      carriers = (ticket['direct_flights'] + return_flights).collect {|fl| fl['airline']}.uniq
      carriers.size == 1 ? carriers[0] : nil
    end
  end

  def map topic, record, stamp
    begin
      ticket = record['tickets'].sort {|a, b| a['total'] <=> b['total']}[0]
      unless ticket.nil?
        pc = plotting_carrier(ticket) 
        emit({'carriers' => [pc]  ,record['params_attributes']['origin_iata'] + '-' + record['params_attributes']['destination_iata'] => {pc => 1}}) unless pc.nil?
      end
    rescue
      nil
    end
  end

  def reduce data
    tor = data.inject({}) do |ac, entry|
      ac.merge(entry) do |acc, a1, a2|
        if acc == 'carriers'
          (a1 + a2).uniq
        else
          a1.merge(a2) do |k, v1, v2|
            v1 + v2
          end
        end
      end
    end
    puts tor
    tor    
  end

  def csv data
    tor = 'Direction'
    carriers = data.delete 'carriers'
    carriers.each do |k|
      tor << ',' + k 
    end
    tor << "\n"
    data.each do |k, v|
      line = k
      carriers.each do |g|
        line += ',' 
        line += v[g].to_s unless v[g].nil?
      end
      tor << line + "\n"
    end
    tor
  end
end

end
