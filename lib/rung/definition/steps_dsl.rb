module Rung
  module Definition
    module StepsDSL
      def steps_definition
        @steps_definition ||= []
      end

      def step(action = nil, &block)
        add_step(action, &block)
      end

      def tee(action = nil, &block)
        add_step(action, ignore_result: true, &block)
      end

      def failure(action = nil, &block)
        add_step(action, run_on: :failure, ignore_result: true, &block)
      end

      def always(action = nil, &block)
        add_step(action, run_on: :any, ignore_result: true, &block)
      end

      def wrap(wrapper, &block)
        if wrapper && block
          nested_steps = calculate_block_nested_steps(&block)
          add_nested_step wrapper, nested_steps
        else
          if respond_to?(:add_global_wrapper)
            add_global_wrapper(wrapper, &block)
          else
            raise Error("Global wrappers can be defined only on the operation level")
          end
        end
      end

      private

      def add_step(action, options = {}, &block)
        step = if block
          Step.new(block, **options, from_block: true)
        else
          Step.new(action, options)
        end
        steps_definition.push(step)
      end

      def add_nested_step(operation, nested_steps)
        steps_definition.push(NestedStep.new(operation, nested_steps))
      end

      def calculate_block_nested_steps(&block)
        with_new_steps_definition do
          instance_exec(&block)
          steps_definition
        end
      end

      def with_new_steps_definition
        old_steps_definition, @steps_definition = @steps_definition, []
        yield
      ensure
        @steps_definition = old_steps_definition
      end
    end
  end
end
