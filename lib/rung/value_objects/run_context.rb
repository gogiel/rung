module Rung
  class RunContext
    def initialize(steps_context:, base_operation:, state:)
      @steps_context = steps_context
      @base_operation = base_operation
      @state = state
      @failed = false
    end

    attr_reader :steps_context, :base_operation, :state

    def fail!
      @failed = true
    end

    def failed?
      @failed
    end

    def success?
      !failed?
    end
  end
end
