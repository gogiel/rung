# order: 51
Feature: Fail fast
:!hardbreaks:
When a fail-fast step is executed and the operation is a failure then
no next step is executed, including `always` and `failure` steps.

It doesn't matter if a failure is caused by the fail-fast step itself or if it
was caused by any previous step, it behaves the same way.

  Scenario: When step with `fail_fast` fails the execution is immediately stopped
    Given definition
    """ruby
    class Operation < Rung::Operation
      step(fail_fast: true) do
        print_to_output "Hello"
        false
      end

      step do
        print_to_output " World!"
      end
    end
    """
    When I run
    """
    @result = Operation.new.call
    """
    Then I see output
    """
    Hello
    """
    And I can assure that
    """
    @result.failure?
    """

  Scenario: Any kind of step can use `fail_fast`
    Given definition
    """ruby
    class Operation < Rung::Operation
      step do
        print_to_output "Hello"
        false
      end

      failure fail_fast: true do
        print_to_output "...Goodbye!"
      end

      step do
        print_to_output " World!"
      end
    end
    """
    When I run
    """
    @result = Operation.new.call
    """
    Then I see output
    """
    Hello...Goodbye!
    """
    And I can assure that
    """
    @result.failure?
    """
