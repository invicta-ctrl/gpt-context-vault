# Project routing policy

## Current routing profile

Reference the account-wide `current-routing-profile.json` and verify the installed
catalog before dispatch. Do not duplicate model assignments in this project policy;
record only approved project-specific stricter limits or exclusions.

## Verified capability catalog

Record the exact installed Codex version and the model aliases, reasoning
values, sandbox modes, agents, hooks, and `codex exec` flags verified for this
project. Unknown values must be rejected.

## Logical routes

Map task tiers to the current profile's orchestrator, single Terra writer, and
read-only worker roles. Record catalog evidence, Ox eligibility state, and review date.

## Safe stops

Block invalid refinements, material conflicts, dirty or divergent repositories,
destructive/external-write work without approval, missing context, and route
mismatches.

## Verification

Name the allowlisted deterministic commands for documentation, focused, full,
and release profiles. Reuse verification only when the redacted source,
configuration, test, dependency, and external-state fingerprints all match.
Do not permit a worker to invent shell commands.

