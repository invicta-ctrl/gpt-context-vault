---
schema_version: 1
status: active
scope: protocols
last_reviewed: 2026-07-24
source_basis: Earl's explicit instruction after context compaction and usage-limit interruptions during a long-running production workflow
---

# Context Compaction Survival Protocol

## Purpose

This protocol makes long-running agent work recoverable when a conversation is compacted, a model or session changes, context becomes unreliable, or usage limits interrupt execution.

It applies account-wide to non-trivial software, deployment, migration, research, and externally stateful workflows unless an authoritative project repository defines a stricter protocol.

Its central rule is:

> A compacted conversation summary is never operational truth. Durable repository records and verified external state are operational truth.

## Authority boundary

The Context Vault defines this reusable governance only.

Project-specific runtime state must remain in the authoritative project repository and approved private configuration or evidence locations.

Authority after compaction is:

1. Earl's current explicit instruction;
2. the active project's accepted specification and amendments;
3. the active project's repository instructions;
4. `.codex/CURRENT.md` and the current verified checkpoint or handoff;
5. current Git and provider state;
6. stable Context Vault governance;
7. compacted summaries, native memory, and chat history as hints only.

When a compacted summary conflicts with durable project or provider evidence, ignore the summary and reconcile from durable evidence.

## Required durable resume chain

A project using long-running or externally stateful agents must maintain:

- project `AGENTS.md` instructions;
- `.codex/CURRENT.md` as the small operational pointer;
- the current accepted specification, amendment, step packet, or phase record;
- the latest verified checkpoint or handoff;
- private configuration and evidence references outside Git when required.

Projects may also keep a dedicated `.codex/RESUME_CAPSULE.md`, but it must not duplicate or contradict `.codex/CURRENT.md`. When both exist, `.codex/CURRENT.md` must link to the active capsule and state which file governs each field.

## Mandatory compaction-resume block

For long-running, multi-phase, deployment, migration, release, or provider-mutating work, `.codex/CURRENT.md` or the active checkpoint must include a concise block using these canonical labels:

```text
COMPACTION_RESUME_SCHEMA: 1
UPDATED_AT: <ISO-8601 timestamp>
PROJECT: <project ID or name>
REPOSITORY: <owner/repository>
BRANCH: <active branch>
WORKTREE: <path or identifier>
REPOSITORY_HEAD: <exact SHA>
UPSTREAM_HEAD: <exact SHA or unknown>
VERIFIED_THROUGH_COMMIT: <exact implementation SHA>
DEPLOYED_RUNTIME: <environment and exact SHA/version>
HANDOFF_METADATA_HEAD: <exact SHA when different>
ACTIVE_SPEC: <path and version>
ACTIVE_STEP_OR_PHASE: <identifier>
STATUS: <BLOCKED | READY | ACTIVE | VERIFYING | COMPLETE>
COMPLETED_AND_ACCEPTED: <bounded list>
EXTERNAL_STATE: <resources changed and verified state>
DATABASE_STATE: <schema, migrations, row-count or reconciliation summary>
BACKUP_AND_ROLLBACK: <backup reference and rollback point>
VERIFICATION_EVIDENCE: <commands, counts, CI, browser/provider evidence>
OPEN_DEFECTS_AND_RISKS: <bounded list>
OWNER_ACTION_REQUIRED: <none or one exact action>
NEXT_EXACT_ACTION: <single next command or bounded action>
DO_NOT_REPEAT_WITHOUT_VERIFICATION: <consequential writes>
READ_FIRST: <smallest authoritative read set>
OFF_LIMITS: <areas not to touch>
SECRETS_AND_PRIVATE_DATA: referenced outside Git; not recorded here
```

The block must be concise and decision-relevant. It is not a transcript, raw log, or narrative diary.

## Mandatory checkpoint triggers

Write or refresh the durable resume block:

1. before an expected model or session switch;
2. immediately after the system reports context compaction;
3. when the conversation becomes long, heavily tool-driven, or difficult to reconstruct reliably;
4. when a usage-limit warning appears;
5. before and after a consequential external mutation;
6. after a migration, deployment, merge, import, restore, backup, release, provider configuration change, or production smoke run;
7. after resolving a material blocker;
8. before pausing for an owner browser action;
9. before ending a session with incomplete work;
10. at every verified project handoff.

When remaining context or usage cannot be measured, checkpoint after every consequential external milestone and before beginning a different major module or phase.

## Pre-compaction procedure

When compaction is expected or risk is high:

1. stop starting new broad work;
2. finish or safely abort the current atomic operation;
3. verify the latest Git and external results;
4. update the compaction-resume block;
5. update the current checkpoint or handoff;
6. record exact tests and external evidence;
7. commit and push redacted metadata when authorized;
8. confirm secrets and private data are excluded;
9. state the single next exact action;
10. only then continue, switch sessions, or allow the task to pause.

Do not write optimistic or inferred completion into the checkpoint.

## Post-compaction rehydration procedure

After compaction, a fresh session, or a usage-limit interruption:

1. read the applicable Context Vault `AGENTS.md` only for account-wide routing;
2. resolve the authoritative project repository;
3. read the project `AGENTS.md` chain;
4. read `.codex/CURRENT.md`;
5. read the current checkpoint or handoff and only the listed active context;
6. inspect Git branch, worktree, `HEAD`, upstream, and unexplained commits;
7. verify deployed runtime, database, provider, CI, and migration state when relevant;
8. compare durable evidence with the compacted summary;
9. reconcile every material contradiction before mutation;
10. resume from `NEXT_EXACT_ACTION` only when its prerequisites remain true.

Do not re-onboard the entire repository unless targeted reconciliation cannot restore reliable state.

## Three-state identity rule

Always distinguish:

1. **Repository state** — branch and exact repository `HEAD`;
2. **Deployed runtime state** — exact environment, Worker/application version, artifact hash, or deployment SHA;
3. **Handoff metadata state** — documentation or pointer commit that may be newer than the deployed implementation.

Never claim the deployed runtime equals repository `HEAD` merely because a documentation-only commit followed the deployment.

Never overwrite one of these identities with another in order to make the record appear simpler.

## Consequential-write replay protection

Before repeating any consequential action, verify whether the prior attempt succeeded.

This applies to:

- database migrations;
- imports and exports;
- deployments;
- merges and tags;
- releases;
- branch deletion;
- email or notification sends;
- evidence uploads;
- Google Sheet or Drive writes;
- Cloudflare resource creation or binding;
- secret updates;
- backup and restore;
- production smoke mutations;
- destructive or compensating corrections.

Required verification may include:

- provider status;
- resource existence;
- idempotency key result;
- migration table;
- deployment version;
- commit ancestry;
- row counts and reconciliation;
- audit event;
- object hash;
- receipt or correlation ID.

If the result is uncertain, reconcile first. Do not blindly retry.

## Evidence and completion rules

A compacted summary may say that work is complete, but completion is valid only when durable evidence confirms:

- accepted scope;
- implementation commit;
- required tests;
- CI state;
- deployment identity;
- migration and data reconciliation;
- browser or provider acceptance;
- rollback or recovery evidence when required;
- unresolved defects and risk status.

Use distinct states:

```text
IMPLEMENTED
DEPLOYED
OPERATIONALLY_ACCEPTED
```

Do not collapse them into one `complete` claim.

## Continuous execution compatibility

When an accepted project plan authorizes continuous execution across named phases:

- checkpoint and continue after each verified phase;
- do not require a new chat merely because one phase ended;
- do not skip the durable checkpoint;
- do not continue into a phase whose prerequisites are unverified;
- do not reinterpret continuous authorization as permission to bypass privacy, recovery, reconciliation, or fail-closed gates.

When continuous execution is not explicitly authorized, follow the project's normal step-completion and stop rule.

## Owner-action pauses

When an unavoidable owner-only browser action is required, record:

- exact provider and environment;
- exact action;
- current safe state;
- work already completed;
- independent work that may continue;
- resume verification required after the owner acts.

Request only one precise action.

Never ask the owner to paste secrets into chat.

## Privacy and redaction

Resume records must never contain:

- passwords or password hashes;
- temporary credentials;
- API keys or tokens;
- session cookies;
- MFA or recovery codes;
- private keys;
- raw Student IDs, contact numbers, or protected personal data;
- private email bodies;
- confidential provider identifiers when a safe alias or private path is sufficient;
- raw logs or chat dumps.

Reference private files by approved path or alias without copying their contents.

## Failure behavior

When durable state is missing, stale, or contradictory:

1. do not guess;
2. do not trust compaction memory;
3. preserve current work;
4. reconcile the smallest authoritative state set;
5. repair the resume chain;
6. record the uncertainty and its resolution;
7. continue only after the active boundary is reliable.

A missing resume record is a workflow defect. Repair it before additional substantial or externally stateful work.

## Adoption rule

For an existing project:

1. add the mandatory rule to project `AGENTS.md` or inherit it explicitly from the Context Vault;
2. verify `.codex/CURRENT.md` exists and is bounded;
3. add the canonical compaction-resume labels;
4. link the current checkpoint or handoff;
5. add deterministic validation when practical;
6. test a fresh-session resume using only the durable read set;
7. confirm no secrets or project runtime data were moved into the Context Vault.

## Verification checklist

Before trusting a resumed agent, confirm:

- [ ] Project repository is authoritative.
- [ ] Active `AGENTS.md` chain was read.
- [ ] `.codex/CURRENT.md` was read.
- [ ] Branch, worktree, repository `HEAD`, and upstream were verified.
- [ ] Deployed runtime identity was verified independently.
- [ ] Handoff metadata identity is distinguished.
- [ ] Active specification and step or phase are known.
- [ ] Database schema, migrations, backups, and reconciliation are known.
- [ ] Required tests and CI evidence are known.
- [ ] Consequential writes are listed under replay protection.
- [ ] Open defects and risks are explicit.
- [ ] The next exact action is bounded.
- [ ] No secrets or protected personal data are present.
- [ ] Compacted conversation content is treated as a hint only.
