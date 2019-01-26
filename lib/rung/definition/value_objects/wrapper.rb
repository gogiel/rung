module Rung
  module Definition
    class Wrapper
      def initialize(wrapper, inner_steps)
        @wrapper = wrapper
        @inner_steps = inner_steps
      end

      attr_reader :wrapper, :inner_steps
    end
  end
end
