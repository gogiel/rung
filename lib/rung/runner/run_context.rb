module Rung
  module Runner
    class RunContext
      def initialize(steps_definition:, operation_instance:, state:)
        @steps_definition = steps_definition
        @operation_instance = operation_instance
        @state = state
        @failed = false
      end

      attr_reader :steps_definition, :operation_instance, :state

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
