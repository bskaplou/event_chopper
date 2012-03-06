module T
  def m
    'z'
  end

  module_function :m

  class C
    include T
    def initialize
      puts m
    end
  end

end

T::C.new
