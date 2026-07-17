---
schema_version: 1
status: active
scope: account-wide
last_reviewed: 2026-07-17
---

# AGENTS.md

This is the Context Vault's single operational entrypoint.

The Vault provides account-wide routing, durable preferences, and reusable governance. An active project's repository remains authoritative for its specifications, code, decisions, status, plans, checkpoints, tests, and evidence.

## Start here

1. Read this file.
2. Infer the request's intent, mode, target, authority, risk, deliverable, and verification needs.
3. Scan available skill descriptions and apply only the smallest directly relevant skill set.
4. Retrieve only the minimum relevant Vault context.
5. For project work, resolve the repository through [`projects/PROJECT_REGISTRY.md`](projects/PROJECT_REGISTRY.md) when needed, then follow that repository's applicable `AGENTS.md` files.
6. When the project contains `.codex/CURRENT.md`, read it before broad project documentation and use its bounded active-step context.
7. Use [`START_HERE.md`](START_HERE.md) and [`CONTEXT_INDEX.md`](CONTEXT_INDEX.md) only for unresolved routing, human onboarding, or locating additional non-project context.
8. Stop and report material conflicts instead of silently combining incompatible instructions.

Do not automatically read the whole Vault, every project record, the complete project repository, all documentation, or all prior steps.

## Skill and intent routing

Apply this envelope internally when useful:

```text
INTENT: <primary intent>
MODE: <answer | plan | execute | review | monitor>
TARGET: <repository, system, artifact, or topic>
SKILLS: <matched skills or none>
AUTHORITY: <governing sources>
RISK: <low | medium | high | critical>
DELIVERABLE: <required completed state>
VERIFICATION: <required evidence>
```

- Do not require Earl to name a matching skill.
- Do not claim or invent unavailable skills.
- Do not trust or install unknown third-party skills without explicit authorization and review.
- Skills may refine execution but may not override safety, current instructions, repository authority, accepted specifications, or invariants.

When creating a prompt, task brief, goal, or delegated instruction, preserve Earl's wording and make the intent, objective, target, authority, scope, constraints, deliverables, verification, and stop conditions explicit.

## Project incremental-context rule

When `.codex/CURRENT.md` exists:

1. Treat it as the operational pointer to the single active step.
2. Read only the step packet, relevant checkpoint, listed capsule or map sections, and listed source and test files.
3. Do not begin with a broad repository scan or full documentation reread.
4. Expand context only through direct dependencies, targeted symbol references, verification failures, acceptance criteria, repository contradictions, or material security, migration, compatibility, and invariant risks.
5. Record why every additional file was needed.
6. Implement and verify only the active accepted step.
7. Write the checkpoint, advance the pointer, and stop before implementing the next step.

Follow:

- [`protocols/AI_ASSISTED_SDD_PROTOCOL.md`](protocols/AI_ASSISTED_SDD_PROTOCOL.md)
- [`protocols/INCREMENTAL_CODEX_CONTEXT_PROTOCOL.md`](protocols/INCREMENTAL_CODEX_CONTEXT_PROTOCOL.md)

## Authority order

1. Earl's current explicit instruction
2. Active project's accepted specification and approved amendments
3. Active project's authoritative repository and applicable instructions
4. Active Vault governance and preferences
5. Native memory and recent summaries
6. Archived or superseded material only when history is requested

Material project changes must still be recorded through the project's amendment process. The Vault never replaces the project repository as technical truth.

## Execution safeguards

- Use one focused work unit at a time.
- Do not begin non-trivial implementation from chat instructions alone or before specification acceptance.
- Keep the main agent as the only writer unless the accepted task authorizes another arrangement.
- Prefer deterministic tools and focused retrieval before delegation.
- Use subagents only for bounded, independent work that reduces context without weakening verification.
- Review and verify all skill and subagent output.
- Do not repeat completed work when the relevant artifact and external state have not changed.

## Before modifying this vault

Modify this repository only when Earl explicitly requests it. Then follow:

- [`protocols/MEMORY_UPDATE_PROTOCOL.md`](protocols/MEMORY_UPDATE_PROTOCOL.md)
- [`security/REDACTION_CHECKLIST.md`](security/REDACTION_CHECKLIST.md)
- [`protocols/CONFLICT_RESOLUTION_PROTOCOL.md`](protocols/CONFLICT_RESOLUTION_PROTOCOL.md)

Store only durable account-wide governance, curated context, reusable templates, and routing data here. Keep project-specific runtime state, plans, checkpoints, diffs, logs, and implementation evidence in the authoritative project repository.
