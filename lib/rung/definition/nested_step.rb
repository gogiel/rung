module Rung
  module Definition
    # Nested step definition value object.
    class NestedStep < Step
      # Takes the same named-parameters as {Rung::Definition::Step}
      # @param action [#call, Symbol]
      # @param nested_steps [Array<Rung::Definition::Step>]
      # @param options [Hash] {Rung::Definition::Step} named params
      def initialize(action, nested_steps, options = {})
        super(action, options)
        @nested_steps = nested_steps
      end

      # @return [Array<Rung::Definition::Step>]
      attr_reader :nested_steps

      # @return [true]
      def nested?
        true
      end
    end
  end
end
