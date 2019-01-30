module Rung
  class State
    def initialize(state, success, operation)
      @success = success
      @operation = operation
      @state = state
    end

    def method_missing(method, *args)
      return @state.send(method, *args) if @state.respond_to?(method)
      super
    end

    def respond_to_missing?(method_name, include_private = false)
      @state.respond_to?(method_name, include_private) || super
    end

    attr_reader :operation

    def success?
      @success
    end

    def fail?
      !success?
    end

    alias failure? fail?

    def self.from_run_context(run_context)
      new(run_context.state, run_context.success?, run_context.operation_instance)
    end
  end
end
