# order: 60
Feature: Step wrappers
:!hardbreaks:
It's possible to wrap around a group of successive steps
with `wrap`.
This is a common use case for surrounding multiple steps in
a database transaction and rolling back when steps inside fail.

Wrapper interface is the same as for any other step.
It requires an object responding to `call()` or `call(state)`.
The only difference is that it also receives a block.

Yielding the block calls inner steps. It returns `false` if
any of the inner steps failed or `true` otherwise.

Example usage:
```ruby
class Operation < Rung::Base
  class TransactionWrapper
    def self.call(state)
      return if state.fail?
      ActiveRecord::Base.transaction do
        success = yield
        raise ActiveRecord::Rollback unless success
      end
    end
  end

  wrap TransactionWrapper do
    step :create_new_entity
    step :update_counter
  end
end
```

  Scenario: Defining a wrapper that prints before and after step calls
    Given definition
    """ruby
    class Operation < Rung::Base
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

      wrap Wrapper do
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
