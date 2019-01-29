# order: 80
Feature: Exceptions handling

  Scenario: All exceptions are raised
    Given definition
    """ruby
    class Operation < Rung::Operation
      step { raise "Oh no!" }
    end
    """
    When I run
    """
    begin
      Operation.new.call(output_text: "Hello ")
    rescue => e
      print_to_output e.message
    end
    """
    Then I see output
    """
    Oh no!
    """

  Scenario: Exception can be caught in a wrapper
    Given definition
    """ruby
    class Operation < Rung::Operation
      class Wrapper
        def self.call(state)
          yield
        rescue
          print_to_output "Exception handled"
          state[:exception_handled] = true
        end
      end

      wrap Wrapper

      step { print_to_output "Hello World!\n"; raise "oops!" }
    end
    """
    When I run
    """
    @result = Operation.new.call
    """
    Then I see output
    """
    Hello World!
    Exception handled
    """
    And I can assure that
    """
    @result.state == { exception_handled: true }
    """
