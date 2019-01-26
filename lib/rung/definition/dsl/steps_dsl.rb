module Rung
  module StepsDSL
    def steps_context
      @steps_context ||= StepsContext.new
    end

    def step(reference = nil, &block)
      step = if block
        Step.new(block, pass_context: true)
      else
        Step.new(reference)
      end
      steps_context.add_step(step)
    end

    def wrap(wrapper, &block)
      inner_steps = calculate_block_steps(&block)
      steps_context.add_step(Wrapper.new(wrapper, inner_steps))
    end

    def failure(reference = nil, &block)
      step = if block
        FailureStep.new(block, pass_context: true)
      else
        FailureStep.new(reference)
      end
      steps_context.add_step(step)
    end

    private

    def calculate_block_steps(&block)
      old_steps_context = @steps_context
      begin
        @steps_context = StepsContext.new
        instance_exec(&block)
        @steps_context
      ensure
        @steps_context = old_steps_context
      end
    end
  end
end
