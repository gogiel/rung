module Rung
  class RunContext
    def initialize(steps:, base_operation:, state:)
      @steps = steps
      @base_operation = base_operation
      @state = state
      @failed = false
    end

    attr_reader :steps, :base_operation, :state

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
