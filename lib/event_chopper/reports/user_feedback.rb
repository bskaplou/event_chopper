module EventChopper

class UserFeedback < Base
  def event_types
    ['user_feedback_report', 'search_result']
  end

  def map topic, record, stamp
    if topic == 'user_feedback_report'
      answers = record['answers'].keep_if {|k, v| v == 'true'}
      if record['success']
        answers['success'] = 1
      else
        answers['failure'] = 1
      end
      answers = Hash[answers.keys.map {|k| [k, 1]}]
      puts answers
      emit({record['gate_id'] => answers})
      emit({'total' => answers})
    elsif topic == 'search_result'
      gates = record['gates_info'].inject({}) do |acc, g|
        acc[g['id']] = g['label']
        acc
      end
      emit({'gates' => gates})
    end
  end

  def reduce data
    tor = data.inject({}) do |acc, entry|
      acc.merge(entry) do |k, v1, v2|
        if k == 'gates'
          v2
        else
          v1.merge(v2) do |kd, v3, v4|
            v3 + v4
          end
        end
      end
    end
    tor
  end
end

end
