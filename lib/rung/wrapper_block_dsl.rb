module Rung
  class WrapperBlockDSL
    include DSL

    def initialize
      @steps = []
    end

    attr_reader :steps
  end
end
