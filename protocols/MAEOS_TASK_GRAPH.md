# MAEOS finite task graphs

Formal task graphs are optional for simple or linear work. The root creates one before a burst above four readers or any fan-out whose dependencies are non-trivial. Every node records:

```text
NODE ID
OBJECTIVE
DEPENDENCIES
ROLE
READ/WRITE MODE
OWNED PATHS OR READ SCOPE
EXCLUSIONS
INPUTS
DELIVERABLE
VERIFICATION
STOP CONDITION
```

The root validates dependencies, exclusive write ownership, capacity, and authority before dispatch. Graphs describe work; they do not create a scheduler, authorize worktrees, or authorize extra workers. No node may add nodes, spawn children, or widen its scope.
