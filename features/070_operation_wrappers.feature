# order: 70
Feature: Operation wrappers
:!hardbreaks:
It is possible to define global wrappers on the Operation level using `around` call.

  Scenario: Operation can have multiple global wrappers
  Wrappers are called in the order they are defined.
    Given definition
    """ruby
    class Operation < Rung::Operation
      class Wrapper
        def initialize(name)
          @name = name
        end

        def call
          print_to_output "#{@name} start\n"
          yield
          print_to_output "#{@name} done\n"
        end
      end

      around Wrapper.new("1")
      around Wrapper.new("2")

      step { print_to_output "Hello World!\n" }
    end
    """
    When I run
    """
    Operation.new.call(variable: true)
    """
    Then I see output
    """
    1 start
    2 start
    Hello World!
    2 done
    1 done

    """
