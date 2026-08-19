---
schema_version: 1
status: active
scope: account-wide
last_reviewed: 2026-08-19
---

# GPT Context Vault

This private repository is Earl Adriano's curated, version-controlled context vault for ChatGPT, Codex, and future AI-assisted workflows.

It stores only stable or currently useful context, project summaries, routing rules, update protocols, security controls, reusable prompts, and templates.

It is **not**:

- a complete ChatGPT export;
- a raw transcript archive;
- a replacement for project repositories;
- a secrets store;
- an automated memory database;
- a store for live project plans, checkpoints, diffs, logs, or runtime state;
- a substitute for current direct instructions.

## How the system is divided

| Layer | Primary purpose |
|---|---|
| Native ChatGPT memory | Lightweight personal preferences and recurring background |
| General ChatGPT chats | Everyday questions, temporary work, and unrelated conversations |
| ChatGPT Projects | Focused workspaces for large, long-running projects |
| `gpt-context-vault` | Curated account-wide context, routing, and reusable governance |
| Individual project repositories | Authoritative specifications, code, decisions, plans, checkpoints, tests, evidence, and project status |

## Source-of-truth hierarchy

1. Earl's current explicit instruction
2. The active project's accepted specification and approved amendments
3. The authoritative repository and applicable project policy
4. Active context in this repository
5. Native memory and relevant recent context
6. Archived or superseded information

Current direct instructions override older stored context, but material project changes must still be recorded through the active repository's amendment process.

## Reading workflow

1. Start with the canonical [AGENTS.md](AGENTS.md).
2. Classify the request and retrieve only the minimum relevant Vault context.
3. For project-specific work, consult [projects/PROJECT_REGISTRY.md](projects/PROJECT_REGISTRY.md) only when routing is needed.
4. Follow the authoritative project repository, its project extension, current pointer, and accepted specification.
5. When the project has `.codex/CURRENT.md`, use it as the pointer to the single active step and bounded initial read set.
6. Use [START_HERE.md](START_HERE.md) and [CONTEXT_INDEX.md](CONTEXT_INDEX.md) only for human onboarding, unresolved routing, or locating additional non-project context.
7. Stop retrieving once the task is adequately grounded.

Do not reread the whole Vault or an entire project repository by default.

## Incremental Codex workflow

For step-by-step software work, the Vault defines reusable governance while live continuation artifacts stay in the project repository:

```text
Vault AGENTS.md
    -> project AGENTS.md and project extension
    -> project .codex/CURRENT.md
    -> active step packet
    -> listed source and test files
    -> implementation and verification
    -> verified checkpoint
    -> advance pointer and stop
```

See:

- [`protocols/AI_ASSISTED_SDD_PROTOCOL.md`](protocols/AI_ASSISTED_SDD_PROTOCOL.md)
- [`protocols/INCREMENTAL_CODEX_CONTEXT_PROTOCOL.md`](protocols/INCREMENTAL_CODEX_CONTEXT_PROTOCOL.md)
- [`protocols/CONTEXT_COMPACTION_SURVIVAL_PROTOCOL.md`](protocols/CONTEXT_COMPACTION_SURVIVAL_PROTOCOL.md)
- [`templates/INCREMENTAL_CODEX_PROJECT_SETUP_TEMPLATE.md`](templates/INCREMENTAL_CODEX_PROJECT_SETUP_TEMPLATE.md)

## Update workflow

Routine updates should be reviewed before they are committed:

1. Identify persistent candidates from a conversation or authoritative project source.
2. Classify each as stable, active, temporary, superseded, or archived.
3. Check conflicts, authority, privacy, and redaction.
4. Prepare the minimum necessary file changes.
5. Review the proposed update or accepted governance amendment.
6. Commit only approved changes.
7. Update the appropriate index and recent-changes record.

Codex is optional for routine maintenance. Small updates may be prepared in a normal ChatGPT conversation and committed manually.

## Codex instruction refinement and routing

The reusable Codex routing standard lives in [`automation/codex-model-routing/`](automation/codex-model-routing/). It defines how natural instructions are classified, when rough or partial requests receive a read-only structured refinement, how model and reasoning tiers are selected, and when work must safe-stop for ambiguity, authority conflicts, approval, or unsupported capabilities.

Project repositories remain authoritative for technical facts, source code, tests, commands, and current status. A project may adopt the standard through its own `.codex/` configuration and local launcher, but live prompts, refined briefs, route decisions, logs, diffs, secrets, and build artifacts remain local to that project and are not stored in this vault. Model identifiers and capability checks must be verified per installation rather than copied blindly between projects.

## Privacy model

This repository should remain private. Secrets, credentials, exact residential addresses, government identifiers, banking information, raw chat exports, and unnecessary sensitive records do not belong here.

See:

- [`security/DATA_POLICY.md`](security/DATA_POLICY.md)
- [`security/REDACTION_CHECKLIST.md`](security/REDACTION_CHECKLIST.md)
- [`security/PROHIBITED_CONTENT.md`](security/PROHIBITED_CONTENT.md)

## Current scope

The Vault includes:

- stable response and working preferences;
- Civil Engineering and Structural Engineering context;
- thesis constraints;
- account-wide project registry;
- curated project routing summaries;
- retrieval, update, handoff, conflict, SDD, incremental-context, and compaction-survival protocols;
- canonical AGENTS governance, registry, project-extension sources, and deterministic drift tooling;
- privacy and redaction controls;
- reusable prompts and project templates.

It intentionally excludes raw chat ingestion, live project runtime state, unrestricted agent execution, last-writer-wins governance synchronization, and semantic-indexing services unless separately specified and accepted. Registered AGENTS replicas use an explicit, registry-driven, dry-run-first synchronization and verification workflow.

## Architecture

```text
General ChatGPT or Codex
          |
          v
  gpt-context-vault
          |
          +-- account-wide routing and preferences
          +-- reusable governance and templates
          +-- canonical AGENTS policy and registry
          +-- project registry
                         |
             +-----------+-----------+
             v                       v
     project repository       project repository
  specs, code, plans,      research, sources,
  checkpoints, evidence    status, and evidence
```

Repository: `https://github.com/invicta-ctrl/gpt-context-vault`
