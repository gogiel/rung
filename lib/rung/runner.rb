module Rung
  class Runner
    def initialize(steps, initial_state, run_context)
      @steps = steps
      @state = initial_state
      @run_context = run_context
    end

    def call
      run_success = iterate

      Result.new(run_success, @state)
    end

    private

    def iterate
      @steps.each do |step|
        step_result = call_runnable(step)
        return false unless step_result
      end

      true
    end

    def call_runnable(step)
      runnable = step_to_runnable(step)

      if step.pass_context
        runnable.arity.zero? ? @run_context.instance_exec(&runnable) : @run_context.instance_exec(@state, &runnable)
      else
        runnable.arity.zero? ? runnable.call : runnable.call(@state)
      end

    end

    def step_to_runnable(step)
      operation = step.operation
      begin
        case operation
        when Symbol, String
          @run_context.method(operation)
        when Proc
          operation
        else
          operation.method(:call)
        end
      rescue
        operation
      end
    end
  end
end
