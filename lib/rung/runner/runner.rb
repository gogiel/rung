module Rung
  module Runner
    class Runner
      def initialize(operation_instance, initial_state)
        @context = RunContext.new(operation_instance, {}.merge(initial_state))
      end

      extend Forwardable
      def_delegators :@context,
        :steps_definition, :operation_instance,
        :around_callbacks, :around_each_callbacks,
        :success?, :stopped?, :fail!, :stop!

      def call
        with_callbacks(around_callbacks) { iterate(steps_definition) }

        current_state
      end

      private

      def with_callbacks(callbacks, second_argument: nil, &block)
        callbacks.reverse.inject(block) do |inner, callback|
          lambda do
            CallHelper.call callback.action, current_state, operation_instance,
              callback.from_block, second_argument, &inner
          end
        end.call
      end

      def iterate(steps_definition)
        steps_definition.each(&method(:run_step))

        success?
      end

      def run_step(step)
        return if stopped?
        return unless step.run?(success?)

        step_success = with_callbacks(
          around_each_callbacks, second_argument: step
        ) { call_step(step) }

        handle_failure(step) unless step_success
      end

      def call_step(step)
        step.nested? ? call_nested_step(step) : call_simple_step(step)
      end

      def call_nested_step(nested)
        CallHelper.call nested.action, current_state, operation_instance do
          iterate nested.nested_steps
        end
      end

      def call_simple_step(step)
        CallHelper.call step.action, current_state, operation_instance,
          step.from_block
      end

      def current_state
        @context.to_state
      end

      def handle_failure(step)
        fail! unless step.ignore_result?
        stop! if step.fail_fast?
      end
    end
  end
end
