module Rung
  module Runner
    module CallHelper
      class << self
        def call(action, state, operation_instance, from_block = false, second_argument = nil, &block)
          raise "Can't pass block when from_block is enabled" if block && from_block
          runnable = to_runnable(action, operation_instance)
          arity = runnable.arity

          if from_block
            case arity
            when 0
              operation_instance.instance_exec(&runnable)
            when 1
              operation_instance.instance_exec(state, &runnable)
            else
              operation_instance.instance_exec(state, second_argument, &runnable)
            end
          else
            case arity
            when 0
              runnable.call(&block)
            when 1
              runnable.call(state, &block)
            else
              runnable.call(state, second_argument, &block)
            end
          end
        end

        private

        def to_runnable(action, operation_instance)
          case action
          when Symbol, String
            operation_instance.method(action)
          when Proc
            action
          else
            action.method(:call)
          end
        rescue NameError
          action
        end
      end
    end
  end
end
