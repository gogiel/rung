# order: 20
Feature: Success and failure
:!hardbreaks:
Value returned from step call is important. Successful step should
return truthy value (anything other than `false` or `nil`).

If step returns falsy value (`false` or `nil`) then
the operation is marked as failed. All next steps are not executed.

Result of the Operation call (`Rung::Runner::Result` object)
can be either a success or a failure. Result has `success?` and `failure?` methods.

  Scenario: When all steps return truthy value the result is a success
    Given definition
    """ruby
    class Operation < Rung::Base
      step do
        # do something...
        true
      end

      step :second_step

      def second_step
        2 + 2
      end
    end
    """
    When I run
    """
    @result = Operation.new.call
    """
    Then I can assure that
    """
    @result.success? == true
    """
    And I can assure that
    """
    @result.failure? == false
    """

  Scenario: When at least one step returns a falsy value then the result is a failure
    Given definition
    """ruby
    class Operation < Rung::Base
      step do
        # do something...
        true
      end

      step :second_step

      def second_step
        nil
      end
    end
    """
    When I run
    """
    @result = Operation.new.call
    """
    Then I can assure that
    """
    @result.success? == false
    """
    And I can assure that
    """
    @result.failure? == true
    """

  Scenario: When a step fails then the next steps are not executed
    Given definition
    """ruby
    class Operation < Rung::Base
      step do
        print_to_output "Hello"
        true
      end

      step do
        # something went wrong, retuning false
        false
      end

      step do
        print_to_output "World"
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
    """
