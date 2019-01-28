# order: 50
Feature: Other steps
:!hardbreaks:

`step` and `failure` are the basic step types.
For the convenience there are also two additional step
types defined:

* `tee` - works the same way as `step` but ignores the return value
* `always` - executes on both success and failure. Return value is not checked

.Table Step behaviours
|===
|Step name|Execute on success|Execute on failure|Ignore return value

|step|✓|✗|✗
|failure|✗|✓|✓
|tee|✓|✗|✓
|always|✓|✓|✓

  Scenario: `tee` step result is not checked
    Given definition
    """ruby
    class Operation < Rung::Operation
      tee do
        print_to_output "Hello "
        false
      end

      step do
        print_to_output "World!"
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

  Scenario: `tee` is not executed when operation is failed
    Given definition
    """ruby
    class Operation < Rung::Operation
      step do
        print_to_output "Hello"
        false # fail
      end

      tee do
        print_to_output "World!"
      end
    end
    """
    When I run
    """
    Operation.new.call
    """
    Then I see output
    """
    Hello
    """


  Scenario: `always` is called when operation is successful
    Given definition
    """ruby
    class Operation < Rung::Operation
      step do
        print_to_output "Hello "
      end

      always do
        print_to_output "World!"
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

  Scenario: `always` is called when operation is failed
    Given definition
    """ruby
    class Operation < Rung::Operation
      step do
        print_to_output "Hello "
        false # fail
      end

      always do
        print_to_output "World!"
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

  Scenario: state object provides information about operation success with `success?` and `fail?`
    Given definition
    """ruby
    class Operation < Rung::Operation
      step do
        print_to_output "Hello"
        false # fail
      end

      always do |state|
        print_to_output " World!" if state.success?
        print_to_output " There!" if state.fail?
      end
    end
    """
    When I run
    """
    Operation.new.call
    """
    Then I see output
    """
    Hello There!
    """
