---
schema_version: 1
status: active
scope: account-wide
last_reviewed: 2026-07-17
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
2. Active project's accepted specification and approved amendments
3. Active project's authoritative repository
4. Active context in this repository
5. Native ChatGPT saved memory and recent summaries
6. Archived or superseded information

Current direct instructions override older stored context, but material project changes must still be recorded through the active repository's amendment process.

## Reading workflow

1. Start with [`AGENTS.md`](AGENTS.md).
2. Classify the request and retrieve only the minimum relevant Vault context.
3. For project-specific work, consult [`projects/PROJECT_REGISTRY.md`](projects/PROJECT_REGISTRY.md) when routing is needed.
4. Follow the authoritative project repository and its applicable `AGENTS.md` files.
5. When the project has `.codex/CURRENT.md`, use it as the pointer to the single active step and bounded initial read set.
6. Use [`START_HERE.md`](START_HERE.md) and [`CONTEXT_INDEX.md`](CONTEXT_INDEX.md) only for human onboarding, unresolved routing, or locating additional non-project context.
7. Stop retrieving once the task is adequately grounded.

Do not reread the whole Vault or an entire project repository by default.

## Incremental Codex workflow

For step-by-step software work, the Vault defines reusable governance while live continuation artifacts stay in the project repository:

```text
Vault AGENTS.md
    -> project AGENTS.md
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
- retrieval, update, handoff, conflict, SDD, and incremental-context protocols;
- privacy and redaction controls;
- reusable prompts and project templates.

It intentionally excludes automatic synchronization, raw chat ingestion, project runtime state, unrestricted agent execution, and semantic-indexing services unless separately specified and accepted.

## Architecture

```text
General ChatGPT or Codex
          │
          ▼
  gpt-context-vault
          │
          ├── account-wide routing and preferences
          ├── reusable governance and templates
          └── project registry
                         │
             ┌───────────┴───────────┐
             ▼                       ▼
     project repository       project repository
  specs, code, plans,      research, sources,
  checkpoints, evidence    status, and evidence
```

Repository: `https://github.com/invicta-ctrl/gpt-context-vault`
