module Rung
  module StepsDSL
    def steps
      @steps ||= Steps.new
    end

    def step(reference = nil, &block)
      step = if block
        Step.new(block, pass_context: true)
      else
        Step.new(reference)
      end
      steps.push(step)
    end

    def wrap(wrapper, &block)
      inner_steps = resolve_block_steps(&block)
      steps.push(Wrapper.new(wrapper, inner_steps))
    end

    def resolve_block_steps(&block)
      old_steps = @steps
      begin
        @steps = Steps.new
        instance_exec(&block)
        @steps
      ensure
        @steps = old_steps
      end
    end
  end
end
