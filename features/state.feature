# order: 3
Feature: State

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
