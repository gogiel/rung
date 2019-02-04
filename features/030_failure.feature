# order: 30
Feature: Success and failure
:!hardbreaks:
Rung gem is based on
link:https://fsharpforfunandprofit.com/rop/[Railway oriented programming]
idea. If you are not familiar with this concept I highly recommend
watching link:https://vimeo.com/113707214[Scott Wlaschin's presentation] first.

Value returned from step call is important. Successful step should
return truthy value (anything other than `false` or `nil`).

If step returns falsy value (`false` or `nil`) then
the operation is marked as failed. All next steps are not executed.

Result of the Operation call (`Rung::State` object)
can be either a success or a failure.
It can be checked using `State` has `success?` and `fail?`
(with `failed?`, `failure?` aliases) methods.

  Scenario: When all steps return truthy value the result is a success
    Given definition
    """ruby
    class Operation < Rung::Operation
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
    And I can assure that `fail?` alias works
    """
    @result.fail? == false
    """
    And I can assure that `failed?` alias works
    """
    @result.failed? == false
    """

  Scenario: When at least one step returns a falsy value then the result is a failure
    Given definition
    """ruby
    class Operation < Rung::Operation
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
    class Operation < Rung::Operation
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
