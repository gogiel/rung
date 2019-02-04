module Rung
  module Definition
    # Step definition value object.
    class Step
      include ValueObject
      # rubocop:disable Metrics/LineLength

      # @param action [#call, Symbol]
      # @param from_block [Boolean] true when steps is defined using
      #  a Ruby block
      # @param run_on [:success, :failure, :any]
      #  - :success - step runs on operation success
      #  - :failure - step runs on operation failure
      #  - :any - steps is always called
      # @param ignore_result [Boolean] result check behaviour
      # @param fail_fast [Boolean]
      def initialize(action, from_block: false, run_on: :success, ignore_result: false, fail_fast: false)
        # rubocop:enable Metrics/LineLength
        @action = action
        @from_block = from_block
        @run_on = run_on
        @ignore_result = ignore_result
        @fail_fast = fail_fast
      end

      attr_reader :action, :from_block

      # @param success [Boolean] operation current success state
      # @return [Boolean]
      # Determine whether the step should run under given operation state.
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

      # @return [false]
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
