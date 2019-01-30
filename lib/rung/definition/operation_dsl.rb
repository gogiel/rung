module Rung
  module Definition
    module OperationDSL
      def around_callbacks
        @around_callbacks ||= []
      end

      def around_each_callbacks
        @around_each_callbacks ||= []
      end

      def around(action = nil, &block)
        around_callbacks.push callback_from_definition(action, &block)
      end

      def around_each(action = nil, &block)
        around_each_callbacks.push callback_from_definition(action, &block)
      end

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
