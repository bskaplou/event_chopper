module EventChopper

class ReductionStore
  def initialize parent
    @store = parent
    @key = nil
    @id = nil
    @value = nil
  end

  def flush
    @store.put @key, @value, @id unless @key.nil?
  end

  def put key, value, id = NOID
    if key.to_s != @key.to_s or id.to_s != @id.to_s
      flush
      @key = key
      @id = id
    end
    @value = value
  end

  def get key, id = NOID
    if key.to_s == @key.to_s and id.to_s == @id.to_s
      @value
    else
      @store.get key, id
    end
  end

  def del key, id = NOID
    flush
    @key = nil
    @id = nil
    @store.del key, id
  end
end

end
