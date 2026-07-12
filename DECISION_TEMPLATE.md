---
schema_version: 1
status: active
scope: security
last_reviewed: 2026-07-12
---

# Data Policy

This repository is intended to remain private.

## Allowed content

- Stable response and working preferences
- Minimal academic context
- Project summaries
- Approved decisions
- Active constraints
- Retrieval and update protocols
- Security policies
- Reusable prompts and templates

## Data principles

- Data minimization
- Least privilege
- Repository-scoped access
- Review before persistence
- No secrets in Git
- No unnecessary third-party personal data
- Current instructions override older stored context

## Restricted or prohibited content

Do not store:

- passwords;
- API keys;
- access tokens;
- session cookies;
- recovery codes;
- private keys;
- exact residential addresses;
- government identifiers;
- banking credentials;
- unnecessary medical records;
- private third-party messages;
- raw chat exports as active memory;
- unauthorized confidential information.

Use [`REDACTION_CHECKLIST.md`](REDACTION_CHECKLIST.md) before committing context.
