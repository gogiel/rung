module Rung
  module Runner
    module CallHelper
      class << self
        def call(operation, state, operation_instance, pass_context = false, &block)
          raise "Can't pass block when pass_context is enabled" if block && pass_context
          runnable = to_runnable(operation, operation_instance)

          if pass_context
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
