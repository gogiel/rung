module Rung
  module Definition
    class NestedStep
      def initialize(operation, nested_steps)
        @operation = operation
        @nested_steps = nested_steps
      end

      attr_reader :operation, :nested_steps

      def run?(_success)
        true
      end

      def nested?
        true
      end

      def ignore_result?
        true
      end
    end
  end
end
