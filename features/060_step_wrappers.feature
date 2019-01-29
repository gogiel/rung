# order: 60
Feature: Step wrappers
:!hardbreaks:
It's possible to step around a group of successive steps.
This is a common use case for surrounding multiple steps in
a database transaction and rolling back when steps inside fail.

Steps wrapper is defined as a step (of any type, e.g. `step` or `tee`)
with callable wrapper-action and additional
block defining nested steps.

Wrapper-action is a Callable or method name.

Yielding the block calls inner steps. Yield returns `false` if
any of the inner steps failed or `true` otherwise.

Example usage:
```ruby
class Operation < Rung::Operation
  class TransactionWrapper
    def self.call(state)
      return if state.fail?
      ActiveRecord::Base.transaction do
        success = yield
        raise ActiveRecord::Rollback unless success
        true
      end
    end
  end

  step TransactionWrapper do
    step :create_new_entity
    step :update_counter
  end
end
```

  Scenario: Wrapper can yield to execute inner steps
    Given definition
    """ruby
    class Operation < Rung::Operation
      class Wrapper
        def self.call
          print_to_output "Starting\n"
          success = yield
          if success
            print_to_output "\nSuccess!"
          else
            print_to_output "\nFailure!"
          end
        end
      end

      step Wrapper do
        step { print_to_output "Hello " }
        step do |state|
          print_to_output "World!"
          state[:variable] # return variable passed by the user
        end
      end
    end
    """
    When I run
    """
    Operation.new.call(variable: true)
    """
    Then I see output
    """
    Starting
    Hello World!
    Success!
    """
    Then I clear output
    When I run
    """
    Operation.new.call(variable: false)
    """
    Then I see output
    """
    Starting
    Hello World!
    Failure!
    """

  Scenario: Wrappers can be nested
    Given definition
    """ruby
    class Operation < Rung::Operation
      class Wrapper
        def initialize(name)
          @name = name
        end

        def call
          print_to_output "Starting #{@name}\n"
          yield
          print_to_output "Finishing #{@name}\n"
        end
      end

      step Wrapper.new("first") do
        step { print_to_output "Hello\n" }
        step Wrapper.new("second") do
          step { print_to_output "Hi\n" }
        end
      end
    end
    """
    When I run
    """
    Operation.new.call
    """
    Then I see output
    """
    Starting first
    Hello
    Starting second
    Hi
    Finishing second
    Finishing first

    """

  Scenario: step type is important when calling a wrapper
    Given definition
    """ruby
    class Operation < Rung::Operation
      class Wrapper
        def initialize(name)
          @name = name
        end

        def call
          print_to_output "from: #{@name}\n"
          yield
        end
      end

      step do
        print_to_output "RED ALERT\n"
        false
      end

      step Wrapper.new("OK") do
        step { print_to_output "Hurray!\n" }
      end

      failure Wrapper.new("FAIL") do
        failure { print_to_output "Oops!\n" }
      end

      always Wrapper.new("ALWAYS") do
        step { print_to_output "We're done!\n" }
        failure { print_to_output "We're done, but something went wrong!\n" }
      end
    end
    """
    When I run
    """
    Operation.new.call(variable: true)
    """
    Then I see output
    """
    RED ALERT
    from: FAIL
    Oops!
    from: ALWAYS
    We're done, but something went wrong!

    """
