module Rung
  class Runner
    def initialize(steps, initial_state, operation)
      @steps = steps
      @state = State.new initial_state
      @operation = operation
    end

    def call
      run_success = iterate(@steps)

      Result.new(run_success, @state)
    end

    private

    def iterate(steps)
      steps.each do |step|
        step_result = step.is_a?(Wrapper) ? call_wrapper(step) : call_runnable(step)
        return false unless step_result
      end

      true
    end

    def call_wrapper(wrapper)
      run_inner_steps = -> {
        iterate(wrapper.inner_steps)
      }
      runnable = to_runnable(wrapper.wrapper)
      runnable.arity.zero? ? runnable.call(&run_inner_steps) : runnable.call(@state, &run_inner_steps)
    end

    def call_runnable(step)
      runnable = to_runnable(step.operation)

      if step.pass_context
        runnable.arity.zero? ? @operation.instance_exec(&runnable) : @operation.instance_exec(@state, &runnable)
      else
        runnable.arity.zero? ? runnable.call : runnable.call(@state)
      end
    end

    def to_runnable(operation)
      case operation
      when Symbol, String
        @operation.method(operation)
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
