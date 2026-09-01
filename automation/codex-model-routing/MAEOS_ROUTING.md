# MAEOS routing contract

`MAEOS-v1` is the active routing revision. The selector validates a declared route and never dispatches Codex. `ROOT_ORCHESTRATOR` is Sol/High. `READER`, `DOCS_RESEARCH`, `PLANNER`, and ordinary `TESTER` are Luna/Max read-only leaves. `ENGINEER`/`WRITER` is one explicit, authorized writer: fail-closed Ox when eligible; otherwise Terra/High for every native non-Ox implementation, write, and integration task. `BRANCH_COORDINATOR` is Terra/High only when root-authorized and necessary. `REVIEWER` is a fresh Sol/High read-only review lane.

The normal topology begins with zero children. 2–4 readers require independent evidence targets. A fifth or later read-only leaf requires `finite_task_graph=true`, explicit node identity, and no writer overlap; the hard ceiling remains 16. Any child-originated spawn, depth greater than one, automatic fallback, unapproved reviewer, unsupported role, target-writer overlap, stale governance, or manual-gate failure is rejected.
