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
