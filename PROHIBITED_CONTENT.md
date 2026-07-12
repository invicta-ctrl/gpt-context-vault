---
schema_version: 1
status: active
scope: protocols
last_reviewed: 2026-07-12
---

# Memory Update Protocol

## Classification

Every proposed persistent item must be classified as:

- **Stable:** expected to remain useful for months or years;
- **Active:** currently useful but expected to change;
- **Temporary:** useful only for a short task or conversation;
- **Superseded:** previously valid information replaced by newer authority;
- **Archived:** retained for history but excluded from active retrieval by default.

## Required checks

Before writing:

1. Confirm the information comes from the current conversation or an authoritative repository.
2. Store only the minimum useful statement.
3. Check for conflicts with existing context.
4. Apply the source-of-truth hierarchy.
5. Run the privacy and redaction checklist.
6. Identify all files that must change.
7. Prepare the update for review.
8. Commit only after approval.
9. Update indexes and changelogs when appropriate.

Temporary information should generally remain in the conversation.

Do not convert speculation, emotional reactions, rough ideas, or unresolved discussion into stable memory.
