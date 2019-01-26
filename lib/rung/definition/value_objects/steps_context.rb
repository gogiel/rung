module Rung
  class StepsContext
    extend Forwardable

    def initialize
      @steps = []
    end

    def add_step(step)
      @steps.push(step)
    end

    def each_step(&block)
      @steps.each(&block)
    end
  end
end
