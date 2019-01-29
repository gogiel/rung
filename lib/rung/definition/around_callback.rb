module Rung
  module Definition
    class AroundCallback
      def initialize(callback = nil, from_block: false)
        @callback = callback
        @from_block = from_block
      end

      attr_reader :callback, :from_block
    end
  end
end
