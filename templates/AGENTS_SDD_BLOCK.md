# Reusable AGENTS.md SDD Block

Copy and adapt this block into the root `AGENTS.md` or equivalent instruction file of every project repository.

```markdown
## Context and authority

Before project work, consult the connected `gpt-context-vault` beginning with `START_HERE.md` and `CONTEXT_INDEX.md` only as needed for routing. Then read this repository's `AGENTS.md`, ruleset, authoritative project documents, and accepted active specification. The project repository is authoritative for project facts. Do not implement from chat history alone.

## Spec-driven development gate

- Every non-trivial change requires one bounded durable specification before implementation.
- The spec must define scope, non-goals, numbered requirements, numbered acceptance criteria, permissions, risks, verification, rollback/recovery, and stop conditions.
- Implementation may begin only when Earl, or an explicitly delegated manager, marks the spec `ACCEPTED`.
- Implement only the accepted spec. Stop and return it to review before any material scope, requirement, acceptance-criterion, security, data, deployment, or external-write change.
- Completion requires evidence mapped to every acceptance criterion and an updated handoff record.
- Tiny typo/format-only edits may use an inline spec. Emergency security work requires a retrospective spec in the same change record.
```

Recommended companion structure:

```text
AGENTS.md
specs/
├── README.md
├── _templates/
│   └── SPEC_TEMPLATE.md
└── <id>-<slug>/
    └── SPEC.md
```

Projects may add stricter rules, but should not weaken the acceptance gate, authority order, amendment control, traceability, privacy boundary, or external-write permissions without Earl's explicit approval.
