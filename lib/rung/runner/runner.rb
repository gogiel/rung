module Rung
  module Runner
    class Runner
      def initialize(steps_context, initial_state, operation_instance)
        @context = RunContext.new(
          steps_context: steps_context,
          operation_instance: operation_instance,
          state: RunState.new(initial_state)
        )
      end

      extend Forwardable
      def_delegators :@context,
        :steps_context, :operation_instance, :state, :failed?, :success?, :fail!

      def call
        run_success = iterate(steps_context)

        Result.new(run_success, state)
      end

      private

      def iterate(steps_context)
        steps_context.each_step do |step|
          step_result = case step
          when Definition::FailureStep
            call_step(step) if failed?
            true
          when Definition::Step
            success? ? call_step(step) : true
          when Definition::Wrapper
            call_wrapper(step)
          else
            raise Error, "Unexpected Step: #{step}"
          end

          fail! unless step_result
        end

        success?
      end

      def call_wrapper(wrapper)
        CallHelper.call(wrapper.wrapper, state, operation_instance) do
          iterate(wrapper.inner_steps)
        end
      end

      def call_step(step)
        CallHelper.call(step.operation, state, operation_instance, step.pass_context)
      end
    end
  end
end
