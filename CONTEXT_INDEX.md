---
schema_version: 1
status: active
scope: account-wide
last_reviewed: 2026-08-19
---

# Context Index

Use this index only when the root [`AGENTS.md`](AGENTS.md) has not already resolved the required route. Do not read every listed file by default.

| Category | File | Purpose | Authority level | Update frequency |
|---|---|---|---|---|
| Agent routing and canonical governance | [`AGENTS.md`](AGENTS.md) | Sole editable account-wide policy authority; intent, skill, project, bounded-context, compaction-survival, and managed-replica routing | Critical | Through accepted governance changes |
| Start | [`START_HERE.md`](START_HERE.md) | Human onboarding and unresolved-routing fallback | High | Rare |
| Current focus | [`CURRENT_FOCUS.md`](CURRENT_FOCUS.md) | Active priorities | Medium | As priorities change |
| User context | [`profile/USER_CONTEXT.md`](profile/USER_CONTEXT.md) | Minimal working profile | Medium | Rare |
| Response style | [`profile/RESPONSE_PREFERENCES.md`](profile/RESPONSE_PREFERENCES.md) | Preferred answer format and behavior | Medium | As confirmed |
| Working style | [`profile/WORKING_PREFERENCES.md`](profile/WORKING_PREFERENCES.md) | Planning and collaboration preferences | Medium | As confirmed |
| Long-term goals | [`profile/LONG_TERM_GOALS.md`](profile/LONG_TERM_GOALS.md) | Durable goals | Medium | Periodic |
| Civil Engineering | [`academics/CIVIL_ENGINEERING_CONTEXT.md`](academics/CIVIL_ENGINEERING_CONTEXT.md) | General academic context | Medium | Semester or program changes |
| Structural Engineering | [`academics/STRUCTURAL_ENGINEERING_CONTEXT.md`](academics/STRUCTURAL_ENGINEERING_CONTEXT.md) | Structural analysis priorities | Medium | Rare |
| Thesis | [`academics/THESIS_CONSTRAINTS.md`](academics/THESIS_CONSTRAINTS.md) | Current feasibility constraints | High for thesis work | When constraints change |
| Subjects | [`academics/SUBJECT_REGISTRY.md`](academics/SUBJECT_REGISTRY.md) | Current subject index | Medium | Each semester |
| Formula style | [`academics/FORMULA_FORMATTING.md`](academics/FORMULA_FORMATTING.md) | Mathematical formatting rules | Medium | Rare |
| Projects | [`projects/PROJECT_REGISTRY.md`](projects/PROJECT_REGISTRY.md) | Active project directory and authoritative-repository routing | High for project routing | As projects change |
| Stable memory | [`memory/STABLE_MEMORY.md`](memory/STABLE_MEMORY.md) | Curated durable facts | Medium | Only when confirmed |
| Active context | [`memory/ACTIVE_CONTEXT.md`](memory/ACTIVE_CONTEXT.md) | Temporary but currently useful context | Medium | Regular review |
| Recent changes | [`memory/RECENT_CHANGES.md`](memory/RECENT_CHANGES.md) | Latest approved context and governance updates | Medium | After meaningful updates |
| Superseded | [`memory/SUPERSEDED_CONTEXT.md`](memory/SUPERSEDED_CONTEXT.md) | Replaced information | Historical only | When conflicts are resolved |
| Retrieval protocol | [`protocols/CONTEXT_RETRIEVAL_PROTOCOL.md`](protocols/CONTEXT_RETRIEVAL_PROTOCOL.md) | Minimal-context retrieval process | High | Rare |
| Update protocol | [`protocols/MEMORY_UPDATE_PROTOCOL.md`](protocols/MEMORY_UPDATE_PROTOCOL.md) | Persistent-memory update process | High | Rare |
| Conflict protocol | [`protocols/CONFLICT_RESOLUTION_PROTOCOL.md`](protocols/CONFLICT_RESOLUTION_PROTOCOL.md) | Resolving contradictory context | High | Rare |
| AI-assisted SDD | [`protocols/AI_ASSISTED_SDD_PROTOCOL.md`](protocols/AI_ASSISTED_SDD_PROTOCOL.md) | Account-wide specification, implementation, review, testing, security, and Git gates | High for software projects | As engineering workflow improves |
| Incremental Codex context | [`protocols/INCREMENTAL_CODEX_CONTEXT_PROTOCOL.md`](protocols/INCREMENTAL_CODEX_CONTEXT_PROTOCOL.md) | Bounded active-step reading, plans, checkpoints, handoffs, and anti-rescan rules | High for Codex projects | As continuation workflow improves |
| Context-compaction survival | [`protocols/CONTEXT_COMPACTION_SURVIVAL_PROTOCOL.md`](protocols/CONTEXT_COMPACTION_SURVIVAL_PROTOCOL.md) | Durable resume blocks, post-compaction rehydration, provider-state reconciliation, and replay protection | High for long-running and externally stateful work | As continuation workflow improves |
| Codex routing | [`automation/codex-model-routing/README.md`](automation/codex-model-routing/README.md) | Reusable instruction-refinement and model-routing governance | Operational | As workflows improve |
| AGENTS registry | [`governance/agents/AGENTS_REGISTRY.json`](governance/agents/AGENTS_REGISTRY.json) | Canonical, managed-replica, extension, exclusion, gate, and rollback registry | High | When targets or gates change |
| AGENTS audit | [`governance/agents/AGENTS_AUDIT.md`](governance/agents/AGENTS_AUDIT.md) | Exhaustive inventory, hash groups, classifications, and dispositions | Evidence | After authorized audits |
| AGENTS rule matrix | [`governance/agents/AGENTS_RULE_MATRIX.md`](governance/agents/AGENTS_RULE_MATRIX.md) | Universal versus project/local rule disposition and contradiction resolution | High | When policy architecture changes |
| AGENTS operations | [`governance/agents/AGENTS_GOVERNANCE.md`](governance/agents/AGENTS_GOVERNANCE.md) | Change, synchronization, drift, extension, rollback, and recovery workflow | High | Rare |
| AGENTS synchronization | [`automation/agents-governance/README.md`](automation/agents-governance/README.md) | Dry-run-first deterministic sync and verification tooling | Operational | When tooling changes |
| AGENTS consolidation report | [`governance/agents/AGENTS_CONSOLIDATION_REPORT.md`](governance/agents/AGENTS_CONSOLIDATION_REPORT.md) | Current execution state, blockers, preservation, and verification record | Evidence | During this consolidation |
| AGENTS governance specification | [`AGENTS-CONSOLIDATION-001`](governance/agents/specs/AGENTS-CONSOLIDATION-001.md) | Accepted canonicalization, replica, extension, synchronization, rollback, and stop-condition authority | High | When governance changes |
| Security policy | [`security/DATA_POLICY.md`](security/DATA_POLICY.md) | Allowed and prohibited storage | High | Rare |
| Prompts | [`prompts/GENERAL_CONTEXT_PROMPT.md`](prompts/GENERAL_CONTEXT_PROMPT.md) | Reusable assistant prompt with project current-step routing | Operational | As workflows improve |
| Memory template | [`templates/MEMORY_ENTRY_TEMPLATE.md`](templates/MEMORY_ENTRY_TEMPLATE.md) | Standardized persistent-memory entries | Operational | As needed |
| Feature-spec template | [`templates/FEATURE_SPEC_TEMPLATE.md`](templates/FEATURE_SPEC_TEMPLATE.md) | Standard specification and acceptance record for non-trivial project changes | Operational | As workflow improves |
| AI task-brief template | [`templates/AI_TASK_BRIEF_TEMPLATE.md`](templates/AI_TASK_BRIEF_TEMPLATE.md) | One-step implementation instruction with bounded context and verification | Operational | As workflow improves |
| Project agent template | [`templates/PROJECT_AGENTS_TEMPLATE.md`](templates/PROJECT_AGENTS_TEMPLATE.md) | Lean project-level instructions with current-step routing and checkpoint gates | Operational | As workflow improves |
| Incremental project setup | [`templates/INCREMENTAL_CODEX_PROJECT_SETUP_TEMPLATE.md`](templates/INCREMENTAL_CODEX_PROJECT_SETUP_TEMPLATE.md) | Copy-ready project capsule, codebase map, plan, pointer, step packet, checkpoint, and continuation templates | Operational | As continuation workflow improves |
| Archive | [`archive/README.md`](archive/README.md) | Historical material rules | Historical only | Rare |
