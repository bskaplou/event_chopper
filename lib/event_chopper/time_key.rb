require 'date'

module EventChopper

class TimeKey
  def self.now
    self.from_date DateTime.now
  end

  def self.from_date date, size = :minute
    min_tail = (date.min - date.min % 10).to_s.rjust(2, '0')
    r = self.new date.strftime('%Y-%m-%d %H:') + min_tail
    size == :minute ? r : r.parents[STEPS_DEPTH.index(size)]
  end

  def self.from_string str, size = :minute
    #some validation here
    r = self.new str
    size == :minute ? r : r.parents[STEPS_DEPTH.index(size)]
  end

  attr_reader :val

  def hash
    val.hash
  end

  def eql?(other)
    val == other.val
  end

  def year
    val[0, 4].to_i
  end

  def month
    val.size > 5 ? val[5, 2].to_i : 0
  end

  def day
    val.size > 8 ? val[8, 2].to_i : 0
  end

  def hour
    val.size > 11 ? val[11, 2].to_i : 0
  end

  def minute
    val.size > 14 ? val[14, 2].to_i : 0
  end

  def to_datetime
    DateTime.new(year, month, day, hour, minute)
  end


  def initialize stamp
    @val = stamp
  end

  def to_s
    val
  end

  def days_in_month year, month
    (Date.new(year, 12, 31) << (12 - month)).day
  end

  MIN = (0..6).map {|item| (item * 10).to_s.rjust(2, '0')}
  HOUR = (0..24).map {|item| item.to_s.rjust(2, '0')}

  def children
    if val.size == 13
      MIN.map {|item| self.class.new(val + ':' + item)}
    elsif  val.size == 10
      HOUR.map {|item| self.class.new(val + ' ' + item)}.flatten
    elsif val.size == 7
      (1..(days_in_month year, month)).map do |item|
        self.class.new(val + '-' + item.to_s.rjust(2, '0'))
      end
    else
      []
    end
  end

  def parents #order is important
    tor = []
    tor << self.class.new(val[0,13]) if val.size > 13
    tor << self.class.new(val[0,10]) if val.size > 10
    tor << self.class.new(val[0,7]) if val.size > 7
    tor << self.class.new(val[0,4]) if val.size > 4
    tor
  end

  STEPS = {
    :minute => 1.0/24/6,
    :hour => 1.0/24,
    :day => 1.0,
    :month => 25,
    :year => 365
  }
  STEPS_DEPTH = [:hour, :day, :month, :year]

  def till stamp, step = :hour
    to_datetime.step(stamp.to_datetime, STEPS[step]).map do |d|
      r = TimeKey.from_date(d)
      step == :minute ? r : r.parents[STEPS_DEPTH.index(step)]
    end.uniq
  end
end

end
