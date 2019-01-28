module Rung
  module Definition
    module StepsDSL
      def steps_definition
        @steps_definition ||= StepsDefinition.new
      end

      def step(reference = nil, &block)
        add_step(reference, &block)
      end

      def tee(reference = nil, &block)
        add_step(reference, ignore_result: true, &block)
      end

      def failure(reference = nil, &block)
        add_step(reference, run_on: :failure, ignore_result: true, &block)
      end

      def always(reference = nil, &block)
        add_step(reference, run_on: :any, ignore_result: true, &block)
      end

      def wrap(wrapper, &block)
        nested_steps = calculate_block_nested_steps(&block)
        add_nested_step wrapper, nested_steps
      end

      private

      def add_step(reference, options = {}, &block)
        step = if block
          Step.new(block, **options, from_block: true)
        else
          Step.new(reference, options)
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
        old_steps_definition = @steps_definition
        @steps_definition = StepsDefinition.new
        yield
      ensure
        @steps_definition = old_steps_definition
      end
    end
  end
end
