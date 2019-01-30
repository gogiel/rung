# order: 51
Feature: Fail fast
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
