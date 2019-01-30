# order: 200
Feature: Misc
  Scenario: Operation defines .call shorthand class method
    Given definition
    """ruby
    class Operation < Rung::Operation
      step {|state| state[:test] = 42 + state[:input] }
    end
    """
    When I run
    """
    @result1 = Operation.call(input: 1)
    @result2 = Operation.new.call(input: 1)
    """
    And I can assure that
    """
    @result1.to_h == @result2.to_h
    """
