# order: 90
Feature: Around step wrapper
:!hardbreaks:

  Scenario: Step wrapper is called for every step
    Given definition
    """ruby
    class Operation < Rung::Operation
      class Counter
        def initialize
          @count = 0
        end

        def call
          @count += 1
          print_to_output "Step #{@count}\n"
          yield
        end
      end

      around_each Counter.new

      step do
        print_to_output "Hello\n"
      end

      step do
        print_to_output "World\n"
      end
    end
    """
    When I run
    """
    Operation.new.call
    """
    Then I see output
    """
    Step 1
    Hello
    Step 2
    World

    """

  Scenario: Step wrapper receives state and current step
    Given definition
    """ruby
    class Operation < Rung::Operation
      class Logger
        def self.call(state, step)
          result = yield

          print_to_output "State: #{state.to_h}, success: #{state.success?}," \
            "ignores result: #{step.ignore_result?}, nested: #{step.nested?}, result: #{result}\n"

          result
        end
      end

      noop_wrapper = -> (&block) { block.call }

      around_each Logger

      step do |state|
        print_to_output "Hello\n"
        state[:test] = 42
      end

      step noop_wrapper do
        tee do |state|
          state[:test] = 5
          print_to_output "World\n"
          true
        end
      end
    end
    """
    When I run
    """
    Operation.new.call
    """
    Then I see output
    """
    Hello
    State: {:test=>42}, success: true,ignores result: false, nested: false, result: 42
    World
    State: {:test=>5}, success: true,ignores result: true, nested: false, result: true
    State: {:test=>5}, success: true,ignores result: false, nested: true, result: true

    """

  Scenario: Step wrapper returned result is treated as the step result
    Given definition
    """ruby
    class Operation < Rung::Operation
      class Boom
        def self.call(state)
          yield
          print_to_output "Boom!\n"
          false # always return false
        end
      end

      around_each Boom

      tee do |state| # tee step ignores result, so Boom doesn't affect it
        print_to_output "Hello\n"
      end

      step { print_to_output "Beautiful\n" }
      step { print_to_output "World\n" }
    end
    """
    When I run
    """
    @result = Operation.new.call
    """
    Then I see output
    """
    Hello
    Boom!
    Beautiful
    Boom!

    """
    And I can assure that
    """
    @result.success? == false
    """

