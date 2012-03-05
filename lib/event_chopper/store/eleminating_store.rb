module EventChopper

class EliminatingStore
  def initialize parent
    @store = parent
  end

  def eliminate stamp, id = NOID
    stamp.parents.each {|p| del p, id}
  end

  def put key, value, id = NOID
    eliminate key
    @store.put key, value, id
  end

  def get key, id = NOID
    @store.get key, id
  end

  def del key, id = NOID
    @store.del key, id
  end
end

end
