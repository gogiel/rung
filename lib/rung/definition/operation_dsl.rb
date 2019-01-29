module Rung
  module Definition
    module OperationDSL
      def callbacks_definition
        @callbacks_definition ||= []
      end

      def add_global_wrapper(reference = nil, &block)
        callback = if block
          AroundCallback.new block, from_block: true
        else
          AroundCallback.new reference
        end
        callbacks_definition.push callback
      end
    end
  end
end
