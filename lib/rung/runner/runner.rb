module Rung
  class Runner
    def initialize(steps_context, initial_state, operation_instance)
      @context = RunContext.new(
        steps_context: steps_context,
        operation_instance: operation_instance,
        state: RunState.new(initial_state)
      )
    end

    extend Forwardable
    def_delegators :@context, :steps_context, :operation_instance, :state, :failed?, :success?, :fail!

    def call
      run_success = iterate(steps_context)

      Result.new(run_success, state)
    end

    private

    def iterate(steps_context)
      steps_context.each_step do |step|
        step_result = case step
        when FailureStep
          call_runnable(step) if failed?
          true
        when Step
          success? ? call_runnable(step) : true
        when Wrapper
          call_wrapper(step)
        else
          raise Error, "Unexpected Step: #{step}"
        end

        fail! unless step_result
      end

      success?
    end

    def call_wrapper(wrapper)
      run_inner_steps = -> {
        iterate(wrapper.inner_steps)
      }
      runnable = to_runnable(wrapper.wrapper)
      runnable.arity.zero? ? runnable.call(&run_inner_steps) : runnable.call(state, &run_inner_steps)
    end

    def call_runnable(step)
      runnable = to_runnable(step.operation)

      if step.pass_context
        runnable.arity.zero? ? operation_instance.instance_exec(&runnable) : operation_instance.instance_exec(state, &runnable)
      else
        runnable.arity.zero? ? runnable.call : runnable.call(state)
      end
    end

    def to_runnable(operation)
      case operation
      when Symbol, String
        operation_instance.method(operation)
      when Proc
        operation
      else
        operation.method(:call)
      end
    rescue NameError
      operation
    end
  end
end
