module Rung
  class Base
    extend Definition::StepsDSL

    def self.call(initial_state = {})
      new.call(initial_state)
    end

    def call(initial_state = {})
      Runner::Runner.new(self.class.steps_definition, initial_state, self).call
    end
  end
end
