module Rung
  module Definition
    class Callback
      def initialize(action = nil, from_block: false)
        @action = action
        @from_block = from_block
      end

      attr_reader :action, :from_block
    end
  end
end
