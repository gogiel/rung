module Rung
  module Runner
    class Result
      def initialize(success, state)
        @success = success
        @state = state
      end

      def success?
        !!@success
      end

      def failure?
        !success?
      end

      attr_reader :state
    end
  end
end
