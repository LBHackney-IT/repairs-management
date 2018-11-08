class Cache
  def initialize(initial_data = {}, &block)
    @block = block
    @data = initial_data
  end

  def [](key)
    data[key] ||= block.call key
  end

  private

  attr_accessor :data, :block
end
