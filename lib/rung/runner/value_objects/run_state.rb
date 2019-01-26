module Rung
  module Runner
    class RunState
      def initialize(initial_state)
        @state = initial_state
      end

      extend Forwardable
      def_delegators :@state, :[], :[]=
    end
  end
end
