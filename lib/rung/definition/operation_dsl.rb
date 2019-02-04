module Rung
  module Definition
    # DSL for calls that can be executed only on the operation level
    # (doesn't work in nested steps).
    module OperationDSL
      # @return [Array<Rung::Definition::Callback>]
      def around_callbacks
        @around_callbacks ||= []
      end

      # @return [Array<Rung::Definition::Callback>]
      def around_each_callbacks
        @around_each_callbacks ||= []
      end

      # @param action [#call, Symbol]
      # Defines a callback that is executed around operation call
      #
      # @example Using action
      #  around Wrapper
      # @example Using block
      #  around { Transaction { yield } }
      def around(action = nil, &block)
        around_callbacks.push callback_from_definition(action, &block)
      end

      # @param action [#call, Symbol]
      # Defines a callback that is executed around each step call
      #
      # @example Using action
      #  around_each Wrapper
      # @example Using block
      #  around_each { Transaction { yield } }
      def around_each(action = nil, &block)
        around_each_callbacks.push callback_from_definition(action, &block)
      end

      private

      def callback_from_definition(action, &block)
        if block
          Callback.new block, from_block: true
        else
          Callback.new action
        end
      end
    end
  end
end
