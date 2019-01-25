module Rung
  class Base
    class << self
      attr_accessor :steps

      def inherited(base)
        base.steps = Steps.new
      end
    end

    extend StepsDSL

    def self.call(initial_state = {})
      new.call(initial_state)
    end

    def call(initial_state = {})
      Runner.new(self.class.steps, initial_state, self).call
    end
  end
end
