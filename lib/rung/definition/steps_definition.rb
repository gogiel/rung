module Rung
  module Definition
    class StepsDefinition
      extend Forwardable

      def initialize
        @steps = []
      end

      def_delegators :@steps, :push, :each
    end
  end
end
