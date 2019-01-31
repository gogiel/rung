module Rung
  module Definition
    module StepsDSL
      def steps_definition
        @steps_definition ||= []
      end

      def add_generic_step(action, options = {}, &block)
        step = step_from_definition action, **options, &block
        steps_definition.push step
      end

      def step(*args, &block)
        add_step_from_args args, &block
      end

      def tee(*args, &block)
        add_step_from_args args, ignore_result: true, &block
      end

      def failure(*args, &block)
        add_step_from_args args, run_on: :failure, ignore_result: true, &block
      end

      def always(*args, &block)
        add_step_from_args args, run_on: :any, ignore_result: true, &block
      end

      private

      def add_step_from_args(args, options = {}, &block)
        action, action_options = extract_action_and_options!(args)
        add_generic_step action, **options, **action_options, &block
      end

      def extract_action_and_options!(args)
        options = args.last.is_a?(::Hash) ? args.pop : {}
        [args.first, options]
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
        old_steps_definition = @steps_definition
        @steps_definition = []
        yield
      ensure
        @steps_definition = old_steps_definition
      end
    end
  end
end
