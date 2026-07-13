# Project routing policy

## Verified capability catalog

Record the exact installed Codex version and the model aliases, reasoning
values, sandbox modes, agents, hooks, and `codex exec` flags verified for this
project. Unknown values must be rejected.

## Logical routes

Map `fast`, `implementation`, `exploration`, `judgment`, and `deep_review` to
verified model/reasoning pairs. Record the evidence and review date.

## Safe stops

Block invalid refinements, material conflicts, dirty or divergent repositories,
destructive/external-write work without approval, missing context, and route
mismatches.

## Verification

Name the allowlisted deterministic commands for documentation, focused, full,
and release profiles. Do not permit a worker to invent shell commands.

