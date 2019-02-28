module Rung
  module Definition
    class NestedOperation
      include ValueObject

      def initialize(operation, input: nil, output: nil)
        @operation = operation
        @input_map = input
        @output_map = output
      end

      def call(state)
        operation_result = @operation.call(map_state(state, @input_map))
        state.merge!(map_state(operation_result, @output_map))
        operation_result.success?
      end

      private

      def map_state(state, mapper)
        if mapper
          mapper.call(state.data_dup)
        else
          state.data_dup
        end
      end
    end
  end
end
