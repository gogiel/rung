module Rung
  class Wrapper
    def initialize(wrapper, block)
      @wrapper = wrapper
      @block = block
    end

    attr_reader :wrapper, :block
  end
end
