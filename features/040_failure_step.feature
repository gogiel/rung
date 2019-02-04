# order: 40
Feature: Failure Step
:!hardbreaks:
When operations fails next normal steps are no ignored and not executed.

There's a way to react to a failure with special failure steps.

Failure steps can be defined similarly to normal steps (as a block, method, or a callable object).
They are *only* executed when operation has failed.

  Scenario: Failure step is executed when operation fails
    Given definition
    """ruby
    class Operation < Rung::Operation
      step do
        print_to_output "Working..."
        # something went wrong...
        false
      end

      failure do
        print_to_output " Oops!"
      end

      step do
        print_to_output "This won't be executed"
      end
    end
    """
    When I run
    """
    Operation.new.call
    """
    Then I see output
    """
    Working... Oops!
    """

  Scenario: Failure step is not executed when operation doesn't fail
    Given definition
    """ruby
    class Operation < Rung::Operation
      step do
        print_to_output "Working..."
        # everything's fine
        true
      end

      failure do
        print_to_output " Oops!"
      end
    end
    """
    When I run
    """
    Operation.new.call
    """
    Then I see output
    """
    Working...
    """

  Scenario: It's possible to define multiple failure steps
    Given definition
    """ruby
    class Operation < Rung::Operation
      step do |state|
        print_to_output "Working..."
        # something went wrong...
        state[:error] = "404"
        false
      end

      failure do
        print_to_output " Error: "
      end

      failure do |state|
        print_to_output state[:error]
      end
    end
    """
    When I run
    """
    Operation.new.call
    """
    Then I see output
    """
    Working... Error: 404
    """

  Scenario: Failure step is executed only when it's defined after failed step
    Given definition
    """ruby
    class Operation < Rung::Operation
      failure do
        print_to_output "Something's wrong"
      end

      step do
        print_to_output "Working..."
        # something went wrong...
        false
      end

      failure do
        print_to_output " Oops!"
      end
    end
    """
    When I run
    """
    Operation.new.call
    """
    Then I see output
    """
    Working... Oops!
    """
