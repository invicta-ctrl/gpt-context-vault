---
schema_version: 1
status: template
scope: projects
last_reviewed: 2026-07-15
---

# Project `AGENTS.md` Template

Use this as a lean operational entrypoint. Keep durable architecture, rationale, and historical decisions in dedicated repository documentation rather than expanding `AGENTS.md` indefinitely.

---

# AGENTS.md

## Required entry sequence

1. Start with the connected Context Vault and retrieve only the minimum relevant context.
2. Confirm this repository is the authoritative source for project requirements, code, decisions, status, and tests.
3. Read the accepted specification, current status, continuation notes, and any rules in the directories being changed.
4. Stop and report conflicts between chat instructions, the Context Vault, and repository authority. Earl's current explicit instruction has highest authority, but material changes must be recorded as amendments.

## Mandatory skill-registry rule

> You have access to a registry of skills. For every user request, first scan the available skill descriptions. If a skill matches the intent of the request, implicitly invoke that skill's playbook to formulate your response.

- Scan skill descriptions before choosing the execution workflow.
- Select only the smallest directly relevant skill set.
- Do not require Earl to name a skill when the match is clear.
- Do not claim or invent unavailable skills.
- Do not install or trust an unknown third-party skill without explicit authorization and review.
- Skills may refine execution but may not override system safety, current instructions, repository authority, accepted specifications, or project invariants.

## Intent-first automatic routing

Normalize each request into this internal envelope before broad exploration or execution:

```text
INTENT: <primary intent>
MODE: <answer | plan | execute | review | monitor>
TARGET: <repository, system, file, artifact, or topic>
SKILLS: <matched skills or none>
AUTHORITY: <governing specifications and files>
RISK: <low | medium | high | critical>
DELIVERABLE: <required completed state>
VERIFICATION: <evidence required>
```

Infer this structure automatically when safe. Preserve the original instruction and ask only for the smallest genuinely missing decision.

Use one primary intent:

- `QUESTION`
- `RESEARCH`
- `WRITING`
- `DOCUMENT_OR_ARTIFACT`
- `SOFTWARE_FEATURE`
- `BUG_FIX`
- `REFACTOR`
- `TESTING`
- `CODE_REVIEW`
- `REPOSITORY_MAINTENANCE`
- `DEPLOYMENT`
- `MIGRATION`
- `ARCHITECTURE`
- `INCIDENT`
- `OWNER_DECISION`
- `COMMUNICATION`
- `SCHEDULING_OR_MONITORING`

For every generated prompt, goal, task brief, or delegated instruction, place these routing fields near the beginning:

```text
INTENT
OBJECTIVE
TARGET
AUTHORITATIVE SOURCES
IN SCOPE
OUT OF SCOPE
CONSTRAINTS
DELIVERABLES
VERIFICATION
STOP CONDITIONS
```

## Specification gate

- Do not begin non-trivial implementation from chat instructions alone.
- Locate or prepare a written specification covering scope, exclusions, user flows, data structures, invariants, risks, verification, rollback, and acceptance criteria.
- Implement only after the specification is marked accepted.
- Record material scope or behavior changes as amendments before implementation.

## Work-unit discipline

- Work on one focused task or vertical slice at a time.
- Prefer the smallest clear, modular, reviewable diff.
- Do not perform unrelated cleanup.
- Do not add dependencies, abstractions, public API changes, schema changes, or architecture changes without accepted scope.
- Preserve existing behavior unless the accepted specification explicitly changes it.

## Testing and verification

- Add or update tests with every behavior change.
- For bug fixes, reproduce the defect with a failing regression test first when practical.
- Run focused tests, the required full suite, linting, type checks, build checks, and artifact verification.
- Exercise critical workflows with integration or E2E tests.
- Record exact commands and exact results.
- Do not stack further work on an unexplained failing state.

## Diff and security review

Review every final diff for unintended:

- deletions or renames;
- dependency or configuration changes;
- public interface changes;
- schema or migration changes;
- authentication or authorization changes;
- hard-coded secrets;
- sensitive-data exposure;
- domain-invariant changes;
- edits outside accepted scope.

Treat authentication, authorization, payments, sensitive data, production configuration, migrations, and destructive operations as high-risk. Require explicit authorization, rollback planning, and additional verification.

## Git discipline

- Begin non-trivial work from a clean state on a dedicated branch.
- Use small descriptive commits after verified milestones.
- Do not push, merge, rewrite history, delete branches, or perform destructive Git operations without explicit authorization.
- Use Git checkpoints for recovery instead of relying on AI undo behavior.

## Debugging discipline

- Capture the exact error and reproduction steps.
- Compare expected and observed behavior.
- Inspect logs, tests, state, and runtime evidence.
- Rank likely causes before broad changes.
- Change one variable at a time.
- After repeated failed attempts, stop random editing and restart from a verified checkpoint or clean context.

## Skill and subagent discipline

- Prefer deterministic tools and focused retrieval before delegating.
- Keep the main agent as the only writer unless the accepted task explicitly allows otherwise.
- Use lower-cost subagents only for bounded, independent, usually read-only work that reduces context or usage.
- Give every delegated task an explicit intent, target, scope, output limit, and verification requirement.
- Validate skill and subagent output before relying on it.

## Completion report

Every completed task must state:

- routed intent and skills used;
- accepted scope;
- starting and ending repository state;
- files changed;
- behavior implemented;
- acceptance criteria and evidence;
- verification commands and exact results;
- risks, limitations, and amendments;
- rollback information;
- recommended next accepted task.

A task is not complete merely because code was generated or the interface appears to work.
