module EventChopper

class BestGatePrices < Base
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

  def map topic, record, stamp
    begin
      ticket = record['tickets'].sort {|a, b| a['total'] <=> b['total']}[0]
      best_proposal = normalize(record['gates_info'], rates, ticket['native_prices']).sort {|a,b| a['price'] <=> b['price']}[0]
      emit ({'gates' => {best_proposal['name'] => best_proposal['id']}, 
        record['params_attributes']['origin_iata'] + '-' + record['params_attributes']['destination_iata'] => {best_proposal['id'] => 1}})
    rescue
      nil
    end
  end

  def reduce data
    tor = data.inject({}) do |ac, entry|
      ac.merge(entry) do |acc, a1, a2|
        a1.merge(a2) do |k, v1, v2|
          if acc == 'gates'
            v2
          else
            v1 + v2
          end
        end
      end
    end
    tor    
  end

  def csv data
    tor = 'Direction'
    gates = data['gates'].inject({}) do |acc, (key, value)|
      acc[value] = key
      acc
    end
    data.delete 'gates'
    gk = gates.keys
    gk.each do |k|
      tor << ',' + gates[k] 
    end
    tor << "\n"
    data.each do |k, v|
      line = k
      gk.each do |g|
        line += ',' 
        line += v[g].to_s unless v[g].nil?
      end
      tor << line + "\n"
    end
    tor
  end
end

end
