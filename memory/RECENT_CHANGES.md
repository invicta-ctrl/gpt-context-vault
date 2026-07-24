---
schema_version: 1
status: active
scope: memory
last_reviewed: 2026-07-24
---

# Recent Changes

## 2026-07-24 — Context-compaction survival governance approved

- Hardcoded account-wide context-compaction survival rules into the root `AGENTS.md`.
- Classified compacted conversation summaries, native memory, and transcript reconstruction as non-authoritative hints for repository and provider state.
- Added `protocols/CONTEXT_COMPACTION_SURVIVAL_PROTOCOL.md` for durable resume blocks, pre-compaction checkpoints, post-compaction rehydration, and consequential-write replay protection.
- Required long-running and externally stateful projects to preserve separate repository, deployed-runtime, and handoff-metadata identities.
- Standardized a canonical compaction-resume block containing exact Git state, active specification and step, external resources, database migrations, backups, verification evidence, open defects, next exact action, and actions that must not be repeated without verification.
- Required checkpoint refreshes after consequential external mutations, when compaction is reported or likely, when usage limits threaten interruption, and before session/model switches.
- Required fresh or compacted sessions to rehydrate from project `AGENTS.md`, `.codex/CURRENT.md`, the current checkpoint or handoff, Git, CI, and verified provider state before new mutations.
- Preserved the rule that secrets, raw personal data, credentials, private identifiers, runtime logs, and project-specific live state do not belong in the Context Vault.
- Classified this amendment as stable, account-wide agent and software-project governance.
- Source of authority: Earl's explicit instruction after context compaction and usage-limit interruptions during the HAU-USC Logistics v0.7.0 production workflow.

## 2026-07-17 — Incremental Codex context workflow approved

- Reworked the Context Vault into a single-entry routing system: agents begin with root `AGENTS.md` and no longer reread `START_HERE.md` plus the full index when the route is already clear.
- Added `protocols/INCREMENTAL_CODEX_CONTEXT_PROTOCOL.md` to prevent repeated whole-repository scans during step-by-step development.
- Established project-local `PROJECT_CAPSULE.md`, `CODEBASE_MAP.md`, `IMPLEMENTATION_PLAN.md`, step packets, `.codex/CURRENT.md`, and verified step checkpoints as the continuation chain for Codex.
- Required bounded initial read sets and allowed context expansion only through direct dependencies, targeted symbol references, verification failures, acceptance criteria, repository contradictions, or material risk.
- Required each completed step to write a compressed technical checkpoint, advance the current pointer, and stop before implementing the next step.
- Adopted a non-circular Git handoff: a verified implementation commit is followed by a separate metadata commit whose checkpoint and pointer reference the known implementation SHA.
- Required steps to remain `VERIFYING` and not advance when commit authorization or durable evidence is still pending.
- Added a copy-ready incremental project setup template, including the optional `continue-step` skill and deterministic workflow-validation script expectations.
- Updated the account-wide SDD protocol, retrieval protocol, project `AGENTS.md` template, AI task brief, general context prompt, Vault index, and onboarding entrypoint to follow the new bounded-context workflow.
- Preserved the rule that live project plans, current pointers, checkpoints, codebase maps, diffs, test evidence, and runtime state belong in authoritative project repositories rather than the Context Vault.
- Classified this amendment as stable, account-wide software-project and agent governance.
- Source of authority: Earl's explicit request and approval in the 2026-07-17 conversation.

## 2026-07-15 — Intent-first skill routing approved

- Added a root `AGENTS.md` as the Context Vault's account-wide operational routing entrypoint.
- Hardcoded the requirement to scan available skill descriptions for every request and implicitly apply a matching skill playbook.
- Added an intent-first routing envelope covering mode, target, matched skills, authority, risk, deliverable, and verification.
- Standardized generated prompts, goals, task briefs, and delegated instructions around explicit intent, objective, target, authority, scope, constraints, deliverables, verification, and stop conditions.
- Updated the reusable project `AGENTS.md` template, general context prompt, and AI task-brief template so projects can inherit the same routing behavior.
- Preserved the authority rule that active project repositories remain authoritative for project facts and implementation state.
- Required deterministic tools and focused retrieval before lower-cost subagent delegation, with the main agent remaining the default writer.
- Classified this amendment as stable, account-wide project and agent governance.
- Source of authority: Earl's explicit instruction in the 2026-07-15 conversation.

## 2026-07-13 — AI-assisted SDD governance approved

- Reviewed the roadmap.sh Vibe Coding roadmap and adopted its durable engineering safeguards as an account-wide project protocol.
- Added `protocols/AI_ASSISTED_SDD_PROTOCOL.md` to require context-first routing, written and accepted specifications, focused work units, complete diff review, verification evidence, Git checkpoints, security gates, evidence-based debugging, and reusable workflows.
- Added templates for feature specifications, scoped AI implementation briefs, and lean project-level `AGENTS.md` files.
- Strengthened the general project prompt so non-trivial implementation cannot proceed from chat instructions alone or outside accepted scope.
- Confirmed that AI-generated code must be treated as untrusted until reviewed and verified, with Earl remaining the architect, reviewer, risk owner, and final decision-maker.
- Classified this amendment as stable, account-wide project governance.
- Source of authority: Earl's explicit approval in the 2026-07-13 conversation.

## 2026-07-12 — HAU-USC repository registered

- Registered [`invicta-ctrl/hau-usc-logistics-management-system`](https://github.com/invicta-ctrl/hau-usc-logistics-management-system) as the authoritative repository for `PROJ-HAU-USC-LOGISTICS`.
- Confirmed that project requirements, code, decisions, implementation status, tests, and technical documentation belong to the project repository rather than this vault.
- Recorded the current default-branch snapshot as preview version `0.3.0` with a mock browser backend.
- Recorded Apps Script production work as the next documented major phase.
- Added a reminder to recheck the project repository before relying on the registration snapshot.

## 2026-07-12 — Version 1 architecture approved

- Approved the account-wide context-vault architecture.
- Selected `invicta-ctrl/gpt-context-vault` as the repository.
- Adopted a curated-context model instead of raw-chat storage.
- Decided that routine memory updates should be reviewed manually.
- Decided to reserve Codex for substantial repository work rather than ordinary context maintenance.
- Kept major projects in separate authoritative repositories.
