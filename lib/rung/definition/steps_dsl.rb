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

      private

      def add_step(action, options = {}, &block)
        steps_definition.push(step_from_definition(action, options, &block))
      end

      def step_from_definition(action, options, &block)
        if action && block
          NestedStep.new(action, calculate_block_nested_steps(&block), options)
        elsif block
          Step.new(block, **options, from_block: true)
        else
          Step.new(action, options)
        end
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
