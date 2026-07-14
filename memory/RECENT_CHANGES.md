---
schema_version: 1
status: active
scope: memory
last_reviewed: 2026-07-15
---

# Recent Changes

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
