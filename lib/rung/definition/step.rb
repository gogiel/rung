module Rung
  module Definition
    class Step
      # rubocop:disable Metrics/LineLength
      def initialize(action, from_block: false, run_on: :success, ignore_result: false, fail_fast: false)
        # rubocop:enable Metrics/LineLength
        @action = action
        @from_block = from_block if from_block
        @run_on = run_on
        @ignore_result = ignore_result
        @fail_fast = fail_fast
      end

      attr_reader :action, :from_block

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

      def fail_fast?
        @fail_fast
      end
    end
  end
end
