module Rung
  module Runner
    class Runner
      def initialize(steps_definition, initial_state, operation_instance)
        @context = RunContext.new(
          steps_definition: steps_definition,
          operation_instance: operation_instance,
          state: {}.merge(initial_state)
        )
      end

      extend Forwardable
      def_delegators :@context,
        :steps_definition, :operation_instance, :failed?, :success?, :fail!

      def call
        run_success = iterate(steps_definition)

        Result.new(run_success, @context.to_h)
      end

      private

      def iterate(steps_definition)
        steps_definition.each(&method(:run_step))

        success?
      end

      def run_step(step)
        return unless step.run?(success?)

        step_success = call_step(step)

        fail! unless step.ignore_result? || step_success
      end

      def call_step(step)
        step.nested? ? call_nested_step(step) : call_simple_step(step)
      end

      def call_nested_step(nested)
        CallHelper.call(nested.operation, @context, operation_instance) do
          iterate(nested.nested_steps)
        end
      end

      def call_simple_step(step)
        CallHelper.call(step.operation, @context, operation_instance, step.from_block)
      end
    end
  end
end
