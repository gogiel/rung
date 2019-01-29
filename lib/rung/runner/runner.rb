module Rung
  module Runner
    class Runner
      def initialize(operation_instance, initial_state)
        @context = RunContext.new(operation_instance, {}.merge(initial_state))
      end

      extend Forwardable
      def_delegators :@context, :steps_definition, :callbacks_definition,
        :operation_instance, :success?, :fail!, :state

      def call
        run_success = with_callbacks { iterate(steps_definition) }

        Result.new(run_success, state)
      end

      private

      def with_callbacks(&block)
        callbacks_definition.reverse.inject(block) do |inner, callback|
          -> { CallHelper.call(callback.callback, step_state, operation_instance, callback.from_block, &inner) }
        end.call
      end

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
        CallHelper.call(nested.operation, step_state, operation_instance) do
          iterate(nested.nested_steps)
        end
      end

      def call_simple_step(step)
        CallHelper.call(step.operation, step_state, operation_instance, step.from_block)
      end

      def step_state
        State.from_run_context @context
      end
    end
  end
end
