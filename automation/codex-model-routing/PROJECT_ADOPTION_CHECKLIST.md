# Project adoption checklist

## Before implementation

- [ ] Identify the authoritative project repository and current branch.
- [ ] Read the project `AGENTS.md`, status, continuation, architecture, domain,
      security, and testing guidance.
- [ ] Verify the installed Codex version and supported model/reasoning aliases.
- [ ] Confirm whether project-local config, custom agents, hooks, and
      `codex exec --output-schema` are available.
- [ ] Define the project's runtime directory and gitignore it.

## Refinement gate

- [ ] Preserve the original instruction verbatim at runtime only.
- [ ] Validate the refinement schema before routing.
- [ ] Require authoritative context and expose assumptions.
- [ ] Stop on material ambiguity, conflict, destructive action, or low confidence.
- [ ] Keep complete prompts and precise commands proportional.

## Routing core

- [ ] Maintain an allowlist of models, reasoning values, agents, and profiles.
- [ ] Add route examples and deterministic fixtures.
- [ ] Decide subagents and worktrees from ownership, not task size.
- [ ] Map each route to an allowlisted verification profile.
- [ ] Record cost justification and escalation evidence.

## Launcher and review

- [ ] Provide assessment-only and explicit execution modes.
- [ ] Pass the refined brief, never the raw instruction, to a worker.
- [ ] Use read-only sandbox for refinement and review.
- [ ] Never execute arbitrary model-generated shell commands.
- [ ] Run deterministic verification, then independent review.
- [ ] Document disable and rollback behavior.

## Vault hygiene

- [ ] Store only the reusable standard and project adoption reference here.
- [ ] Keep prompts, route JSON, logs, diffs, secrets, and build artifacts out.
- [ ] Link to the project implementation without duplicating technical truth.

