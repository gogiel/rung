module Rung
  module Definition
    class StepsDefinition
      extend Forwardable
      include Enumerable

      def initialize
        @steps = []
      end

      def_delegators :@steps, :each, :push
    end
  end
end
