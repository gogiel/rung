module Rung
  module StepsDSL
    def step(reference = nil, &block)
      step = if block
        Step.new(block, pass_context: true)
      else
        Step.new(reference)
      end
      steps.push(step)
    end

    def wrap(wrapper, &block)
      inner_steps = WrapperBlockDSL.call(&block)
      steps.push(Wrapper.new(wrapper, inner_steps))
    end
  end
end
