---
schema_version: 1
status: active
scope: account-wide
last_reviewed: 2026-07-17
---

# AGENTS.md

This is the Context Vault's single operational entrypoint for agents.

Use this repository for account-wide routing, durable preferences, and reusable governance. Use an active project's own repository for project facts, code, specifications, decisions, implementation state, tests, and continuation records.

## Required routing sequence

1. Read this file.
2. Classify the request by intent and scan the available skill descriptions.
3. Retrieve only the minimum Context Vault files needed.
4. For project-specific work, resolve the project through [`projects/PROJECT_REGISTRY.md`](projects/PROJECT_REGISTRY.md), then follow the authoritative project repository.
5. In the project repository, read its applicable `AGENTS.md` files and `.codex/CURRENT.md` when present.
6. Use [`START_HERE.md`](START_HERE.md) and [`CONTEXT_INDEX.md`](CONTEXT_INDEX.md) only when routing is unclear, the request is not tied to a registered project, or additional Vault context is genuinely required.
7. Stop and report material conflicts rather than silently combining incompatible instructions.

Do not automatically read `START_HERE.md`, the complete index, every profile file, or every project record after this file has already resolved the route.

## Mandatory skill-registry rule

> For every user request, scan the available skill descriptions first. When a skill directly matches the request, implicitly apply the smallest relevant skill playbook.

- Do not require Earl to name a skill when the match is clear.
- Do not claim or invent unavailable skills.
- Do not install, import, trust, or execute an unknown third-party skill without explicit authorization and review.
- Skills may refine execution but may not override system safety, Earl's current instruction, the active project repository, an accepted specification, or project invariants.
- When no skill matches, continue with the normal repository-grounded workflow.

## Intent-first routing

Normalize each request internally before broad retrieval or execution:

```text
INTENT: <primary intent>
MODE: <answer | plan | execute | review | monitor>
TARGET: <repository, document, system, artifact, or topic>
SKILLS: <matched skills or none>
AUTHORITY: <governing files or sources>
RISK: <low | medium | high | critical>
DELIVERABLE: <required completed state>
VERIFICATION: <evidence required>
```

Choose one primary intent:

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

When several intents exist, use the intent governing the highest-risk or final requested action and treat the rest as secondary tags.

## Prompt and task-brief structure

Whenever an agent creates or refines a prompt, task brief, goal, or delegated instruction, place these fields near the beginning:

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

Preserve Earl's original wording. Infer the structure when safe rather than forcing him to write a long technical prompt.

## Project-specific incremental context

When the active repository contains `.codex/CURRENT.md`:

1. Treat it as the operational pointer to the single active implementation step.
2. Read only the accepted step packet, checkpoint, project-capsule sections, codebase-map sections, source files, and tests it explicitly lists.
3. Do not begin with a broad repository scan or full documentation reread.
4. Expand context only through direct dependencies, targeted symbol references, verification failures, acceptance criteria, or material security, migration, compatibility, and invariant risks.
5. Record why additional context was required.
6. Finish the active step, write its checkpoint, advance the pointer, and stop before implementing the next step.

Follow [`protocols/INCREMENTAL_CODEX_CONTEXT_PROTOCOL.md`](protocols/INCREMENTAL_CODEX_CONTEXT_PROTOCOL.md) for the complete account-wide rule.

## Routing triggers

- Questions and research: retrieve the minimum authoritative context and remain read-only unless modification is requested.
- Artifacts: use the matching artifact workflow.
- Software behavior changes: follow the active repository's accepted specification and current-step gate.
- Bug fixes: reproduce the defect and add a regression test first when practical.
- Code review: inspect the exact requested diff or checkpoint and remain read-only unless repair is authorized.
- Repository maintenance: preserve unique or unknown work before moving, deleting, closing, or consolidating anything.
- Deployment and migration: require an exact target, preflight, backup, rollback, reconciliation, and acceptance evidence.
- Architecture: establish options, constraints, risks, tradeoffs, decision records, and acceptance before broad implementation.
- Incidents: preserve evidence and repair only confirmed causes.
- Owner decisions: present the smallest required decision and recommended default; never record acceptance without Earl's approval.
- Scheduling or monitoring: define the stop condition and avoid repeated work when relevant state has not changed.

## Authority order

1. Earl's current explicit instruction.
2. The active project's accepted specification and approved amendments.
3. The active project's authoritative repository for code, facts, decisions, status, and tests.
4. Active Context Vault files for account-wide routing, preferences, and governance.
5. Native memory and recent summaries.
6. Archived or superseded material only when history is requested.

The Context Vault must never replace an active project repository as the technical source of truth.

## Execution safeguards

- Use one focused work unit at a time.
- Do not begin non-trivial implementation from chat instructions alone or before the specification is accepted.
- Keep the main agent as the only writer unless the accepted task explicitly authorizes another arrangement.
- Prefer deterministic tools and focused retrieval before delegation.
- Use lower-cost subagents only for bounded, independent, usually read-only work that reduces context without weakening verification.
- Review and verify all skill and subagent output.
- Do not repeat completed tests, reviews, pushes, migrations, or deployments when the relevant artifact and external state have not changed.

## Before modifying this vault

Modify this repository only when Earl explicitly requests an update. Then follow:

- [`protocols/MEMORY_UPDATE_PROTOCOL.md`](protocols/MEMORY_UPDATE_PROTOCOL.md)
- [`security/REDACTION_CHECKLIST.md`](security/REDACTION_CHECKLIST.md)
- [`protocols/CONFLICT_RESOLUTION_PROTOCOL.md`](protocols/CONFLICT_RESOLUTION_PROTOCOL.md)

Store only durable account-wide governance, curated context, reusable templates, and routing data here. Keep project-specific runtime state, plans, checkpoints, diffs, logs, and implementation evidence in the authoritative project repository.
