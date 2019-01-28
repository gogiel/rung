module Rung
  module Runner
    class RunContext < Hash
      def initialize(steps_definition:, operation_instance:, state:)
        @steps_definition = steps_definition
        @operation_instance = operation_instance
        @failed = false
        merge!(state)
      end

      attr_reader :steps_definition, :operation_instance, :state

      def fail!
        @failed = true
      end

      def fail?
        @failed
      end

      def success?
        !fail?
      end
    end
  end
end
