module Rung
  module Runner
    # Helper used to run actions such as steps and callbacks.
    module CallHelper
      # rubocop:disable Metrics/ParameterLists, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/LineLength
      class << self
        # @param action [#call, Symbol]
        # @param state [Rung::State]
        # @param operation_instance [Rung::Operation]
        # @param action_from_block [Boolean]
        # @param second_argument usually used to provide step to around each callback
        def call(action, state, operation_instance, action_from_block = false, second_argument = nil, &block)
          raise Error, "Can't pass block when action_from_block is enabled" if block && action_from_block

          runnable = to_runnable(action, operation_instance)
          arity = runnable.arity

          if action_from_block
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
# rubocop:enable Metrics/ParameterLists, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/LineLength
