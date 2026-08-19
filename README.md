---
schema_version: 1
status: active
scope: account-wide
last_reviewed: 2026-08-19
---

# GPT Context Vault

This private repository is Earl Adriano's curated, version-controlled context vault for ChatGPT, Codex, and future AI-assisted workflows.

It stores only stable or currently useful context, project summaries, retrieval rules, update protocols, security controls, reusable prompts, and templates.

It is **not**:

- a complete ChatGPT export;
- a raw transcript archive;
- a replacement for project repositories;
- a secrets store;
- an automated memory database;
- a substitute for current direct instructions.

## How the system is divided

| Layer | Primary purpose |
|---|---|
| Native ChatGPT memory | Lightweight personal preferences and recurring background |
| General ChatGPT chats | Everyday questions, temporary work, and unrelated conversations |
| ChatGPT Projects | Focused workspaces for large, long-running projects |
| `gpt-context-vault` | Curated account-wide context and operating rules |
| Individual project repositories | Authoritative requirements, code, decisions, tests, and project status |

## Source-of-truth hierarchy

1. Earls current explicit instruction
2. The active projects accepted specification and approved amendments
3. The authoritative repository and applicable project policy
4. Active context in this repository
5. Native memory and relevant recent context
6. Archived or superseded information

Current direct instructions always override older stored context.

## Reading workflow

1. Start with the canonical [AGENTS.md](AGENTS.md).
2. Continue with [START_HERE.md](START_HERE.md).
3. Use [CONTEXT_INDEX.md](CONTEXT_INDEX.md) to locate only the relevant files.
4. For project-specific work, consult [projects/PROJECT_REGISTRY.md](projects/PROJECT_REGISTRY.md).
5. Follow the authoritative project repository, its project extension, current pointer, and accepted specification.
6. Stop retrieving once the task is sufficiently grounded.

## Update workflow

Routine updates should be reviewed before they are committed:

1. Identify persistent candidates from a conversation or project.
2. Classify each as stable, active, temporary, superseded, or archived.
3. Check conflicts and privacy.
4. Prepare minimal file changes.
5. Review the proposed update.
6. Commit only approved changes.
7. Update the appropriate index and changelog.

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

## Version 1 scope

Version 1 includes:

- stable response and working preferences;
- Civil Engineering and Structural Engineering context;
- thesis constraints;
- account-wide project registry;
- HAU-USC Logistics summary;
- retrieval, update, handoff, and conflict protocols;
- privacy and redaction controls;
- reusable prompts and templates.

Version 1 excludes background or last-writer-wins synchronization, chat-export ingestion, vector databases, bots, APIs, scheduled jobs, and semantic indexing services. AGENTS replicas use an explicit, registry-driven, dry-run-first synchronization and verification workflow.

## Architecture

```text
General ChatGPT
      │
      ▼
gpt-context-vault
      │
      ├── stable account-wide context
      ├── retrieval and update protocols
      └── project registry
                     │
          ┌──────────┴──────────┐
          ▼                     ▼
  project repository     project repository
  code and decisions     research and sources
```

Repository: `https://github.com/invicta-ctrl/gpt-context-vault`
