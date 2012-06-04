require 'date'

module EventChopper

class TimeKey
  PARENTS = {
    :month => :year,
    :day => :month,
    :hour => :day,
    :ten_minutes => :hour,
    :minute => :ten_minutes,
    :half_minute => :minute 
  }

  SIZES = {
    :year => 4,
    :month => 7,
    :day => 10,
    :hour => 13,
    :ten_minutes => 15,
    :minute => 16,
    :half_minute => 20
  }

  def initialize data, type = :ten_minutes
    @data = data.collect {|x| x.nil? ? 0 : x}
    @type = type
  end

  def hash
    @data.hash
  end

  attr_accessor :data, :type

  def eql?(other)
    data == other.data
  end

  def self.from_date dt, type = :ten_minutes
    dt = dt.new_offset '+00:00'
    TimeKey.new [dt.year, dt.month, dt.mday, dt.hour, dt.min / 10, dt.min % 10, dt.sec < 30 ? 0 : 30], type
  end

  def self.now type = :ten_minutes
    TimeKey.from_date DateTime.now.new_offset('+00:00'), type
  end

  def self.from_string str, type = :ten_minutes
    (year, month, day, hour, minutes, seconds) = str.split /-| |:/
    if minutes.nil?
      t_m = 0
      m = 0
    else
      if minutes.size == 1
        t_m = minutes.to_i
        m = 0
      else
        t_m = minutes.to_i / 10
        m = minutes.to_i % 10
      end
    end
    seconds = 0 if seconds.nil?
    TimeKey.new [year.to_i, month.to_i, day.to_i, hour.to_i, t_m, m, seconds.to_i < 30 ? 0 : 30], type
  end

  def two i
    i.to_s.rjust(2, '0')
  end

  def to_s
    "#{@data[0]}-#{two(@data[1])}-#{two(@data[2])} #{two(@data[3])}:#{@data[4]}#{@data[5]}:#{two(@data[6])}"[0, SIZES[@type]]
  end

  def days_in_month year, month
    (Date.new(year, 12, 31) << (12 - month)).day
  end

  def parents
    if @type == :year
      []
    else
      step = TimeKey.new(@data, PARENTS[@type])
      [step, step.parents].flatten
    end
  end

  def children
    case @type
      when :half_minute
        []
      when :minute
        [0, 30].collect {|m| TimeKey.new(@data[0,6] + [m], :half_minute) }
      when :ten_minutes
        (0..9).collect {|m| TimeKey.new(@data[0,5] + [m, 0], :minute) }
      when :hour
        (0..5).collect {|m| TimeKey.new(@data[0,4] + [m, 0, 0], :ten_minutes) }
      when :day
        (0..23).collect {|m| TimeKey.new(@data[0,3] + [m, 0, 0, 0], :hour) }
      when :month
        (1..(days_in_month @data[1], @data[2])).collect {|m| TimeKey.new(@data[0,2] + [m, 0, 0, 0, 0], :day)}
      when :year
        (1..12).collect {|m| TimeKey.new(@data[0,1] + [m, 0, 0, 0, 0, 0], :month)}
    end
  end

  def to_datetime
    DateTime.new @data[0], @data[1], @data[2] , @data[3] , @data[4] * 10 + @data[5], @data[6]
  end

  STEPS = {
    :half_minute => 1.0/24/6/10/2,
    :minute => 1.0/24/6/10,
    :ten_minutes => 1.0/24/6,
    :hour => 1.0/24,
    :day => 1.0,
    :month => 25,
    :year => 365
  }
  STEPS_DEPTH = [:minute, :ten_minutes, :hour, :day, :month, :year]

  def till stamp, step = :hour
    to_datetime.step(stamp.to_datetime, STEPS[step]).map do |d|
      TimeKey.from_date(d, step)
    end.uniq
  end
end

end
