module Rung
  class Operation
    extend Definition::StepsDSL
    extend Definition::OperationDSL

    def self.call(initial_state = {})
      new.call(initial_state)
    end

    def call(initial_state = {})
      Runner::Runner.new(self.class.steps_definition, self.class.callbacks_definition, initial_state, self).call
    end
  end
end
