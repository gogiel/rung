Feature: steps_definition
  There are multiple ways of defining steps.
  Steps definition order is important as they are always executed in order.

  Scenario: Steps can be defined as a Ruby block
    Given definition
    """ruby
    class Operation < Rung::Base
      step do |state|
        state[:what] = "World"
      end

      step do
        print_to_output "Hello "
      end

      step do |state|
        print_to_output state[:what]
      end

      step do
        print_to_output "!"
      end
    end
    """
    When I run
    """
    Operation.new.call
    """
    Then I see output
    """
    Hello World!
    """

  Scenario: Steps can be defined as methods
    Given definition
    """ruby
    class Operation < Rung::Base
      step :set_what_state
      step :print_hello
      step "print_what"
      step :print_bang

      def set_what_state(state)
        state[:what] = "World"
      end

      def print_hello
        print_to_output "Hello "
      end

      def print_what(state)
        print_to_output state[:what]
      end

      def print_bang
        print_to_output "!"
      end
    end
    """
    When I run
    """
    Operation.new.call
    """
    Then I see output
    """
    Hello World!
    """

  Scenario: Steps can be defined as any objects with call method
    Given definition
    """ruby
    class SetWhatState
      def initialize(what)
        @what = what
      end

      def call(state)
        state[:what] = @what
      end
    end

    class PrintHello
      def self.call
        print_to_output "Hello "
      end
    end

    class PrintWhat
      def self.call(state)
        print_to_output state[:what]
      end
    end

    PrintBang = -> { print_to_output "!" }

    class Operation < Rung::Base
      step SetWhatState.new("World")
      step PrintHello
      step PrintWhat
      step PrintBang
    end
    """
    When I run
    """
    Operation.new.call
    """
    Then I see output
    """
    Hello World!
    """
