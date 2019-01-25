module Rung
  class Step
    def initialize(operation, pass_context: false)
      @operation = operation
      @pass_context = pass_context
    end

    attr_reader :operation, :pass_context
  end
end
