module Rung
  # Namespace wrapping classes and DSL used for defining Operation.
  module Definition
    module StepsDSL
      # @!attribute steps_definition [r]
      # @return [Array<Rung::Definition::Step>)]
      # List of steps definitions
      def steps_definition
        @steps_definition ||= []
      end

      # @param action [#call, Symbol]
      # @param options [Hash] named params passed to {Rung::Definition::Step}
      # Generic method of creating a step. Shouldn't be used directly.
      # Instead use more precise methods like {#step} or {#failure}.
      #
      # Requires:
      # - action or block - simple steps
      # - both action and block - nested steps
      #
      # @example Simple step
      #  add_generic_step MyStep.new
      #  add_generic_step { ... }
      # @example Nested step
      #  add_generic_step Wrapper do
      #    add_generic_step :inner_step
      #  end
      # @example Step options
      #  add_generic_step :my_step, fail_fast: true, run_on: :failure
      def add_generic_step(action, options = {}, &block)
        step = step_from_definition action, **options, &block
        steps_definition.push step
      end

      # @see #add_generic_step
      def step(*args, &block)
        add_step_from_args args, &block
      end

      # Defines a step with ignore_result: true
      # @see #add_generic_step
      def tee(*args, &block)
        add_step_from_args args, ignore_result: true, &block
      end

      # Defines a step with run_on: :failure, ignore_result: true
      # @see #add_generic_step
      def failure(*args, &block)
        add_step_from_args args, run_on: :failure, ignore_result: true, &block
      end

      # Defines a step with run_on: :any, ignore_result: true
      # @see #add_generic_step
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
