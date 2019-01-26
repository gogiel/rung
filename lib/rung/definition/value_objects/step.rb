module Rung
  module Definition
    class Step
      def initialize(operation, pass_context: false)
        @operation = operation
        @pass_context = pass_context if pass_context
      end

      attr_reader :operation, :pass_context
    end
  end
end
