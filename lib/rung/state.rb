module Rung
  class State
    include ValueObject

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
    alias failed? fail?
    alias successful? success?
  end
end
