# order: 55
Feature: Nested operations
:!hardbreaks:

  Scenario: Nested Operation can be executed using `nested` helper
    Current state is passed to the nested step.
    Operation output is merged to the caller state.

    Given definition
    """ruby
    class InnerOperation < Rung::Operation
      step do |state|
        state[:output] = state[:input] + 1
      end
    end

    class Operation < Rung::Operation
      step nested(InnerOperation)
    end
    """
    When I run
    """
    @result = Operation.call(input: 1)
    """
    Then I can assure that
    """
    @result[:output] == 2
    """

  Scenario: Nested Operation failure is treated as a step failure
    Given definition
    """ruby
    class InnerOperation < Rung::Operation
      step do
        false # fail
      end
    end

    class Operation < Rung::Operation
      step nested(InnerOperation)
    end
    """
    When I run
    """
    @result = Operation.call(input: 1)
    """
    Then I can assure that
    """
    @result.failure?
    """

  Scenario: Nested Operation input and output can be re-mapped
    Given definition
    """ruby
    class InnerOperation < Rung::Operation
      step do |state|
        state[:output] = state[:input] + 1
      end
    end

    class Operation < Rung::Operation
      step nested(InnerOperation,
        input: ->(state) { {input: state[:value] } },
        output: ->(state) { { calculated: state[:output] } }
      )

      step do |state|
        state[:sum] = state[:calculated] + state[:value]
      end
    end
    """
    When I run
    """
    @result = Operation.call(value: 1)
    """
    Then I can assure that
    """
    @result.to_h == { calculated: 2, value: 1, sum: 3 }
    """
