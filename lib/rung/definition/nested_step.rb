module Rung
  module Definition
    class NestedStep < Step
      def initialize(action, nested_steps, options)
        super(action, options)
        @nested_steps = nested_steps
      end

      attr_reader :nested_steps

      def nested?
        true
      end
    end
  end
end
