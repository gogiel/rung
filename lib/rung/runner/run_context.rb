module Rung
  module Runner
    class RunContext
      extend Forwardable

      def initialize(operation_instance, state)
        @operation_instance = operation_instance
        @state = state
        @failed = false
      end

      def_delegators :operation_class, :steps_definition, :around_callbacks, :around_each_callbacks
      attr_reader :operation_instance, :state

      def operation_class
        operation_instance.class
      end

      def fail!
        @failed = true
      end

      def success?
        !@failed
      end
    end
  end
end
