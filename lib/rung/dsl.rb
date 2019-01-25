module Rung
  module DSL
    attr_accessor :steps

    def inherited(base)
      base.steps = Steps.new
    end

    def step(reference = nil, &block)
      step = if block
        Step.new(block, pass_context: true)
      else
        Step.new(reference)
      end
      steps.push(step)
    end
  end
end
