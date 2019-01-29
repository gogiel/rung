module Rung
  module Definition
    module OperationDSL
      def callbacks_definition
        @callbacks_definition ||= []
      end

      def around(action = nil, &block)
        callback = if block
          AroundCallback.new block, from_block: true
        else
          AroundCallback.new action
        end
        callbacks_definition.push callback
      end
    end
  end
end
