module Rung
  module Runner
    class RunContext
      def initialize(steps_definition:, operation_instance:, callbacks_definition:, state:)
        @steps_definition = steps_definition
        @operation_instance = operation_instance
        @callbacks_definition = callbacks_definition
        @state = state
        @failed = false
      end

      attr_reader :steps_definition, :operation_instance, :state, :callbacks_definition

      def fail!
        @failed = true
      end

      def failed?
        @failed
      end

      def success?
        !failed?
      end
    end
  end
end
