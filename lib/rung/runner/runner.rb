module Rung
  module Runner
    class Runner
      def initialize(operation_instance, initial_state)
        @context = RunContext.new(operation_instance, {}.merge(initial_state))
      end

      extend Forwardable
      def_delegators :@context, :steps_definition, :around_callbacks,
        :operation_instance, :success?, :fail!, :state, :around_each_callbacks

      def call
        run_success = with_callbacks(around_callbacks) { iterate(steps_definition) }

        Result.new(run_success, state)
      end

      private

      def with_callbacks(callbacks, second_argument: nil, &block)
        callbacks.reverse.inject(block) do |inner, callback|
          -> { CallHelper.call(callback.action, step_state, operation_instance, callback.from_block, second_argument, &inner) }
        end.call
      end

      def iterate(steps_definition)
        steps_definition.each(&method(:run_step))

        success?
      end

      def run_step(step)
        return unless step.run?(success?)

        step_success = with_callbacks(around_each_callbacks, second_argument: step) { call_step(step) }

        fail! unless step.ignore_result? || step_success
      end

      def call_step(step)
        step.nested? ? call_nested_step(step) : call_simple_step(step)
      end

      def call_nested_step(nested)
        CallHelper.call(nested.action, step_state, operation_instance) do
          iterate(nested.nested_steps)
        end
      end

      def call_simple_step(step)
        CallHelper.call(step.action, step_state, operation_instance, step.from_block)
      end

      def step_state
        State.from_run_context @context
      end
    end
  end
end
