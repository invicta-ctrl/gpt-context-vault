---
schema_version: 1
status: active
scope: account-wide
last_reviewed: 2026-07-15
---

# AGENTS.md

This file is the operational routing entrypoint for agents using the Context Vault. It supplements [`START_HERE.md`](START_HERE.md), [`CONTEXT_INDEX.md`](CONTEXT_INDEX.md), and the active project's own authoritative `AGENTS.md`.

## Required entry sequence

1. Read this file.
2. Read [`START_HERE.md`](START_HERE.md).
3. Read [`CONTEXT_INDEX.md`](CONTEXT_INDEX.md).
4. Classify the request by intent before broad retrieval or execution.
5. Retrieve only the minimum Context Vault files needed.
6. For project-specific work, open [`projects/PROJECT_REGISTRY.md`](projects/PROJECT_REGISTRY.md), then follow the registered project repository and its own `AGENTS.md`, accepted specification, current status, and continuation records.
7. Stop and report material conflicts rather than silently combining incompatible instructions.

## Mandatory skill-registry rule

> You have access to a registry of skills. For every user request, first scan the available skill descriptions. If a skill matches the intent of the request, implicitly invoke that skill's playbook to formulate your response.

Apply that rule as follows:

- Scan the skill descriptions exposed by the current environment before choosing a workflow.
- Select the smallest set of skills that directly matches the request.
- Use the matched skill's playbook without requiring the user to name the skill.
- Do not claim that a skill was used when it was unavailable or did not match.
- Do not install, import, trust, or execute an unknown third-party skill without explicit authorization and review.
- A skill may refine execution but may never override system safety, Earl's current instruction, this vault's authority rules, the active project repository, or an accepted specification.
- When no skill matches, continue with the normal repository-grounded workflow.

## Intent-first automatic routing

Every request must be normalized into a concise internal intent envelope before work begins. The user does not need to provide these labels when the intent can be inferred safely.

Use this structure:

```text
INTENT: <primary intent>
MODE: <answer | plan | execute | review | monitor>
TARGET: <repository, document, system, artifact, or topic>
SKILLS: <matched skills or none>
AUTHORITY: <files or sources that govern the task>
RISK: <low | medium | high | critical>
DELIVERABLE: <required output or completed state>
VERIFICATION: <evidence required before completion>
```

Choose exactly one primary intent from this routing set:

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

If several intents are present, choose the intent that governs the highest-risk or final requested action and record the others as secondary intent tags.

## Routing triggers

- Questions and research: retrieve the minimum authoritative context and do not modify repositories unless explicitly asked.
- Documents, PDFs, spreadsheets, slides, images, or other artifacts: use the matching artifact skill and its required workflow.
- Software features and behavior changes: follow the active repository's specification gate before implementation.
- Bug fixes: reproduce the defect and add a regression test when practical before repairing it.
- Code review: inspect the exact requested diff or checkpoint and remain read-only unless a repair is explicitly authorized.
- Repository maintenance: inventory and preserve unique or unknown work before moving, deleting, closing, or consolidating anything.
- Deployment and migration: require an exact target, preflight, backup, rollback, reconciliation, and acceptance evidence.
- Architecture: produce options, constraints, threat model, proof, tradeoffs, and an ADR before broad implementation.
- Incidents: preserve evidence and repair only confirmed causes.
- Owner decisions: present the smallest required decision and a recommended default, but never record it as accepted without Earl's approval.
- Scheduling or monitoring: define the stop condition and avoid repeated work when no relevant state changed.

## Prompt and task-brief structure

Whenever an agent creates or refines a prompt, task brief, goal, or delegated instruction, make the intent machine-routable by placing these fields near the beginning:

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

Preserve the user's original wording. Refine rough instructions into this structure internally rather than forcing the user to write a long technical prompt.

## Authority and scope

1. Earl's current explicit instruction.
2. The active project's authoritative repository for project facts, code, status, decisions, and tests.
3. Active Context Vault files for account-wide preferences, retrieval rules, and governance.
4. Native memory and recent summaries.
5. Archived or superseded material only when history is requested.

The Context Vault must not replace an active project repository as the technical source of truth.

## Execution safeguards

- Use one focused work unit at a time.
- Do not begin non-trivial implementation without an accepted specification when the active project requires one.
- Keep the main agent as the only writer unless the active repository explicitly authorizes another arrangement.
- Prefer deterministic tools and focused retrieval before spawning subagents.
- Delegate only bounded, independent, usually read-only work to lower-cost subagents when doing so reduces context or usage without weakening verification.
- Review and verify all skill or subagent output before relying on it.
- Do not repeat completed tests, reviews, pushes, migrations, or deployments when the verified artifact and relevant external state have not changed.

## Before modifying this vault

Only modify this repository when Earl explicitly requests an update. Then follow:

- [`protocols/MEMORY_UPDATE_PROTOCOL.md`](protocols/MEMORY_UPDATE_PROTOCOL.md)
- [`security/REDACTION_CHECKLIST.md`](security/REDACTION_CHECKLIST.md)
- [`protocols/CONFLICT_RESOLUTION_PROTOCOL.md`](protocols/CONFLICT_RESOLUTION_PROTOCOL.md)

Classify this routing policy as stable, account-wide governance. Keep project-specific runtime state in the project repository, not in this vault.
