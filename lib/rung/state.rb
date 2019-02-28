module Rung
  # Execution state.
  # It acts as a Hash.
  #
  # Created when {Rung::Operation} call starts.
  # Steps can mutate it.
  # Returned in an unchanged form to the user from the call.
  class State
    include ValueObject

    def initialize(state, success, operation)
      @state = state
      @success = success
      @operation = operation
    end

    # Internal state Hash methods delegation
    def method_missing(method, *args)
      return @state.send(method, *args) if @state.respond_to?(method)

      super
    end

    def data_dup
      @state.dup
    end

    # Internal state Hash methods delegation
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
    alias failed? fail?
    alias successful? success?
  end
end
