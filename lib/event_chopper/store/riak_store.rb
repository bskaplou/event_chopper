require 'riak'

module EventChopper

class RiakStore
  include EventChopper

  def initialize name, host = 'localhost', port = 1978
    @client = Riak::Client.new
    @bc = @client.bucket name
  end

  def pkey k, i
    k.to_s + '|' + i.to_s
  end

  def get key, id = NOID
    k = pkey key, id
    (@bc.exists? k) ? decode(@bc.get(k).raw_data) : nil
  end

  def put key, val, id = NOID
    v = @bc.get_or_new pkey(key, id)
    v.raw_data = encode(val)
    v.store
  end

  def del key, id = NOID
    @bc.delete pkey(key, id)
  end
end

end
