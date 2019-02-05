# Architecture

Rung Operation is a class that inherits from the base {Rung::Operation} class.

It provides ability of defining the Operation and running (executing) it.

## Definition

Steps and other parts of the Operation definition are saved on the class level.
Operation definition consists of elements such as:

* list of all steps through {Rung::Definition::StepsDSL#steps_definition}
* list of all callbacks through {Rung::Definition::OperationDSL#around_callbacks}
and {Rung::Definition::OperationDSL#around_each_callbacks}

{Rung::Definition::StepsDSL} and
{Rung::Definition::OperationDSL} provide DSL methods to modify the definition.

For example {Rung::Definition::StepsDSL#step} call appends a step to
{Rung::Definition::StepsDSL#steps_definition} Array.
{Rung::Definition::OperationDSL#around} call appends a callback to
{Rung::Definition::OperationDSL#around_callbacks} Array.

Definition elements (value objects) such as
{Rung::Definition::Step}, {Rung::Definition::NestedStep} and {Rung::Definition::Callback}
can be found in {Rung::Definition} namespace.

## Execution

Execution is triggered in {Rung::Operation} by calling {Rung::Operation#call}
with an optional initial state (Hash).

It creates new {Rung::Runner::Runner} instance. Internal state is encapsulated in
{Rung::Runner::RunContext}.

Based on the definition described in the previous paragraph and initial state
Runner iterates over the steps and callbacks in proper order.

Steps and callbacks have access to Hash-like {Rung::State} object through witch they
are able to read current operation state and modify it.

Last iteration of {Rung::State} is also the final result of the operation.
It is returned to a user, who is able to read the status (success/failure) and a state hash.
