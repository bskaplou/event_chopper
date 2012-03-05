require 'tokyotyrant'
require 'yajl'

module EventChopper

class TTStore
  def initialize name, host = 'localhost', port = 1978
    @prefix = name
    @db = TokyoTyrant::RDB::new
    @db.open host, port
  end

  def encode data
    Yajl::Encoder.encode data
  end

  def decode data
    Yajl::Parser.parse data
  end

  def pkey key, id = NOID
    @prefix + ' ' + key.to_s + '|' + id.to_s
  end

  def get key, id = NOID
    t = @db.get pkey(key, id)
    t.nil? ? nil : decode(t)
  end

  def put key, val, id = NOID
    @db.put pkey(key, id),encode(val)
  end

  def del key, id = NOID
    @db.delete pkey(key, id)
  end
end

end
