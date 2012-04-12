module EventChopper

class Z < Base
  def event_types
    ['search', 'click', 'booking']
  end

  def map topic, record, stamp
    puts topic
  end

  def reduce data
  end

end

end
