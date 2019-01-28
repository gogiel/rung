# order: 10
Feature: Operation definition
:!hardbreaks:
Operation defines a business process that consists of multiple steps.

For example when in e-commerce application new order is created then +
the system should update state of the warehouse, send an e-mail, create new waybill etc.

To define Operation create a new class based on `Rung::Operation`.
Inside it you can define steps using Rung DSL.
Steps definition order is important as they are always executed in order.

Steps can communicate with each other and external world using State. When
operation is called then new state object is created (see link:#State[State]).
State is shared between step executions.

There are multiple ways of defining steps.

  Scenario: Steps can be defined as a Ruby block
    Given definition
    """ruby
    class Operation < Rung::Operation
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
    class Operation < Rung::Operation
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

    class Operation < Rung::Operation
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
