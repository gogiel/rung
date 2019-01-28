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

      def [](key)
        state[key]
      end

      def ==(other)
        other.success? == success? && other.state == state
      end

      attr_reader :state
      alias to_h state
    end
  end
end
