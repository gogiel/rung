module Rung
  module Definition
    class NestedStep
      def initialize(action, nested_steps)
        @action = action
        @nested_steps = nested_steps
      end

      attr_reader :action, :nested_steps

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
