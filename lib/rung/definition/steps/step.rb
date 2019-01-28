module Rung
  module Definition
    class Step
      def initialize(operation, from_block: false, run_on: :success, ignore_result: false)
        @operation = operation
        @from_block = from_block if from_block
        @run_on = run_on
        @ignore_result = ignore_result
      end

      attr_reader :operation, :from_block

      def run?(success)
        case @run_on
        when :success
          success
        when :failure
          !success
        when :any
          true
        else
          false
        end
      end

      def nested?
        false
      end

      def ignore_result?
        @ignore_result
      end
    end
  end
end
