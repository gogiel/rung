module Rung
  module Runner
    module CallHelper
      class << self
        def call(operation, state, operation_instance, from_block = false, &block)
          raise "Can't pass block when from_block is enabled" if block && from_block
          runnable = to_runnable(operation, operation_instance)

          if from_block
            runnable.arity.zero? ? operation_instance.instance_exec(&runnable) : operation_instance.instance_exec(state, &runnable)
          else
            runnable.arity.zero? ? runnable.call(&block) : runnable.call(state, &block)
          end
        end

        private

        def to_runnable(operation, operation_instance)
          case operation
          when Symbol, String
            operation_instance.method(operation)
          when Proc
            operation
          else
            operation.method(:call)
          end
        rescue NameError
          operation
        end
      end
    end
  end
end