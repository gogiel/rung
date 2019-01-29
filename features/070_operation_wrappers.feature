# order: 70
Feature: Operation wrappers
It is possible to define global wrapper on the Operation level using `wrapper` call
without nested steps block.

  Scenario: Operation can have multiple global wrappers
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

      wrap Wrapper.new("1")
      wrap Wrapper.new("2")

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
