---
schema_version: 1
status: active
scope: protocols
last_reviewed: 2026-07-12
---

# Chat End Protocol

At the end of a session, choose one outcome.

## No update

Use when the conversation contains only:

- temporary work;
- casual discussion;
- solved one-off questions;
- unconfirmed ideas;
- repeated existing context.

## Proposed memory update

Use when the session confirms:

- a durable preference;
- a meaningful active constraint;
- a changed project priority;
- a corrected or superseded fact.

Follow [`MEMORY_UPDATE_PROTOCOL.md`](MEMORY_UPDATE_PROTOCOL.md).

## Project handoff

Use after substantial repository work, implementation, testing, or a major project decision.

Use [`../prompts/HANDOFF_PROMPT.md`](../prompts/HANDOFF_PROMPT.md).

## Project-repository status update

Use when project code, tests, requirements, decisions, or implementation status changed.

Update the project repository first. Keep this vault limited to a concise cross-project summary.
