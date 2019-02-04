module Rung
  module Definition
    # Callback definition Value object.
    class Callback
      include ValueObject
      # @param action [#call, Symbol]
      # @param from_block [Boolean] true when callback is defined using
      #  a Ruby block
      def initialize(action, from_block: false)
        @action = action
        @from_block = from_block
      end

      # @return [#call]
      attr_reader :action
      # @return [Boolean]
      attr_reader :from_block
    end
  end
end
