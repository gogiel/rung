module Rung
  # @abstract
  # Base class for all user-defined operations
  class Operation
    extend Definition::StepsDSL
    extend Definition::OperationDSL

    # @param initial_state [Hash]
    # @return [Rung::Runner::State]
    # #call shortcut
    def self.call(initial_state = {})
      new.call(initial_state)
    end

    # @param initial_state [Hash]
    # @return [Rung::Runner::State]
    # Starts {Rung::Runner::Runner} and returns its final state
    def call(initial_state = {})
      Runner::Runner.new(self, initial_state).call
    end
  end
end
