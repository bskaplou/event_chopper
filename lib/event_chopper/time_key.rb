require 'date'

module EventChopper

class TimeKey
  def self.now
    self.from_date DateTime.now
  end

  def self.from_date date
    min_tail = (date.min - date.min % 10).to_s.rjust(2, '0')
    self.new date.strftime('%Y-%m-%d %H:') + min_tail
  end

  def initialize stamp
    @val = stamp
  end

  def to_s
    @val
  end

  def days_in_month year, month
    (Date.new(year, 12, 31) << (12 - month)).day
  end

  MIN = (0..6).inject([]) {|acc, item| acc << (item * 10).to_s.rjust(2, '0')}
  HOUR = (0..24).inject([]) {|acc, item| acc << (item).to_s.rjust(2, '0')}
  MONTH = (0..12).inject([]) {|acc, item| acc << (item).to_s.rjust(2, '0')}

  def children
    if @val.size == 13
      MIN.inject([]) {|acc, item| acc << self.class.new(@val + ':' + item)}
    elsif  @val.size == 10
      HOUR.inject([]) {|acc, item| acc << self.class.new(@val + ' ' + item)}.flatten
    elsif  @val.size == 7
      (year, month) = @val.split /\-/, 2
      (1..(days_in_month year.to_i, month.to_i)).inject([]) do |acc, item|
        acc << self.class.new(@val + '-' + item.to_s.rjust(2, '0'))
      end
    else
      []
    end
  end

  def parents
    tor = []
    tor << self.class.new(@val[0,13]) if @val.size > 13
    tor << self.class.new(@val[0,10]) if @val.size > 10
    tor << self.class.new(@val[0,7]) if @val.size > 7
    tor << self.class.new(@val[0,4]) if @val.size > 4
    tor
  end
end

end
