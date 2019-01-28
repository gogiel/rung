# order: 30
Feature: State
:!hardbreaks:
State is a Hash object that is shared between step executions.

It's used to share state between steps and communicate with external world.

User can provide initial state when calling the operation. By default it's empty.

State can be used as the operation output as it is accessible in the result object.

  Scenario: State is shared across step executions
    Given definition
    """ruby
    class Operation < Rung::Base
      step do |state|
        state[:what] = "World!"
      end

      step do
        print_to_output "Hello "
      end

      step do |state|
        print_to_output state[:what]
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

  Scenario: State is available in the result object
    Given definition
    """ruby
    class Operation < Rung::Base
      step do |state|
        state[:output_text] = "Hello "
      end

      step do |state|
        state[:output_text] << "World!"
      end
    end
    """
    When I run
    """
    @result = Operation.new.call
    """
    Then I can assure that
    """
    @result[:output_text] == "Hello World!"
    """

  Scenario: Initial state can be passed to call method
    Given definition
    """ruby
    class Operation < Rung::Base
      step do |state|
        state[:output_text] << "World!"
      end
    end
    """
    When I run
    """
    @result = Operation.new.call(output_text: "Hello ")
    """
    Then I can assure that
    """
    @result[:output_text] == "Hello World!"
    """
    And I can assure that
    """
    @result.state == { output_text: "Hello World!" }
    """
