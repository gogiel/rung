module Rung
  class Base
    extend StepsDSL
    extend OperationDSL

    def self.call(initial_state = {})
      new.call(initial_state)
    end

    def call(initial_state = {})
      Runner.new(self.class.steps, initial_state, self).call
    end
  end
end
