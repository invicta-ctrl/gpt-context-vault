---
schema_version: 1
status: active
scope: astral-bridge-project-extension
extension_id: ASTRAL-BRIDGE-PROJECT-POLICY-V1
target_repository: invicta-ctrl/Astral-Bridge
universal_governance: ..\AGENTS.md
last_reviewed: 2026-08-19
---

# Astral Bridge Project Policy Extension

Read the byte-identical universal root `AGENTS.md` first. This extension preserves Astral Bridge-specific product, bootstrap, protected-source, security, and verification rules.

## Sol Advisor inheritance

Inherit `SOL-ADVISOR-GLOBAL-001` without weakening Astral Bridge protected-source, connector, privacy, recovery, or external-state safeguards. Sol / High selects `solo|delegate|audit|full`; Ox is temporary implementation-only and fail-closed; Luna / Max and Terra / High are the native implementation lanes; fresh Sol / High alone reviews audit/full work.

## Scope

This extension governs the entire Astral Bridge repository.

Do not add nested `AGENTS.md` files. Repository-specific rules belong here unless a future accepted specification explicitly authorizes a narrower extension.

## Authority order

Within Astral Bridge:

1. Earl's current explicit instruction.
2. The active accepted specification named by `.codex/CURRENT.md`, including approved amendments.
3. The universal root policy, this extension, and verified repository state.
4. Current OpenAI/Codex plugin and skill conventions verified from installed tooling or official documentation.
5. Historical notes only when provenance or migration requires them.

Never invent missing authority. Stop on a material contradiction that cannot be resolved safely.

## Active work pointer

Before non-trivial work, read `.codex/CURRENT.md` and the accepted specification it names.

Work on one accepted task or vertical slice at a time. Do not start future phases automatically.

## AB-000 boundary

AB-000 is repository bootstrap only. It authorizes preparation of the canonical Astral Bridge repository, governance, documentation, skills-only plugin shell, marketplace shell, bootstrap design, security posture, and deterministic scaffold verification.

AB-000 does not authorize:

- migration or copying of CodexPro implementation;
- edits, commits, resets, stashes, branch switches, cleans, or pushes in the protected CodexPro source checkout;
- CodexPro-to-Astral Bridge source rebranding;
- native-controller implementation;
- a real Astral Bridge MCP configuration;
- deployment or Cloudflare infrastructure changes;
- credential creation, rotation, collection, or publication;
- OpenAI Plugin Directory submission;
- public release or distribution;
- AB-001 source migration.

A separately accepted specification is required for any later phase.

## Canonical locations

```text
Product: Astral Bridge
Machine identifier: astral-bridge
Local repository: D:\Documents\Codex\Astral-Bridge
Canonical GitHub repository: https://github.com/invicta-ctrl/Astral-Bridge
Protected source checkout: C:\Users\adria\CodexTools\CodexProSource
```

The protected CodexPro source checkout remains read-only to Astral Bridge work until a separate accepted migration specification authorizes otherwise.

## Product identifiers

Use these future-facing identifiers consistently:

```text
Plugin: astral-bridge
Main skill: astral-bridge
Installer skill: astral-install
Future CLI: astral
Environment prefix: ASTRAL_BRIDGE_
Future configuration directory: .astral-bridge
```

Do not rename legacy CodexPro implementation during AB-000.

## Repository shape

Keep the repository simple. Future migrated implementation may use root-level `src/`, `scripts/`, `package.json`, tests, and related files.

Do not force a complex packages/monorepo structure without accepted authority.

The plugin shell remains skills-only until a real MCP/app implementation is migrated and verified. Do not add `.mcp.json`, `mcpServers`, equivalent runtime wiring, or capability claims before that authority exists.

## Security and secrets

Assume Astral Bridge may eventually receive significant local-machine privileges.

Apply:

- least privilege;
- explicit allowed roots;
- secret-path blocking;
- safe/read-only modes;
- approval boundaries;
- auditable operations;
- command restrictions;
- destructive-operation controls;
- no implicit credential collection;
- no credential commits;
- no secret logging;
- reversible install, uninstall, and rollback design.

Never print or commit authentication tokens, passwords, private keys, session secrets, credential files, or recovery material.

## Git safety

Preserve unknown work and remote history.

- Never force-push unless a later accepted specification explicitly authorizes it.
- Never rewrite existing remote history during bootstrap.
- Review the complete diff before committing.
- Commit only files within accepted scope.
- Verify branch, `HEAD`, upstream, and clean/dirty state after Git operations.
- Do not claim a commit or push succeeded without direct verification.
- Do not modify the protected CodexPro checkout from an Astral task.

## AB-000 verification

For AB-000-compatible documentation or governance work, run:

```text
node scripts/verify-scaffold.mjs
```

Do not claim PASS unless the command exits successfully.

Before an AB-000 commit, confirm:

- required scaffold files exist;
- plugin and marketplace JSON parse;
- `.codex/CURRENT.md` points to the accepted AB-000 specification;
- no premature `.mcp.json` exists;
- no CodexPro source has been copied into the repository;
- product identifiers use Astral Bridge naming;
- no superseded product-name leftovers exist;
- no credentials or secret-looking material is staged;
- the protected CodexPro checkout remains in its verified preflight state.

## Stop conditions

Stop rather than improvise when:

- repository identity differs from `invicta-ctrl/Astral-Bridge`;
- the canonical local directory contains unexpected work;
- GitHub authentication cannot be verified for an authorized remote action;
- the task would require modifying the protected CodexPro checkout;
- secrets are found in material proposed for commit;
- current plugin conventions materially conflict with the accepted scaffold;
- remote history would need to be overwritten;
- public-release restrictions conflict with a proposed publication action;
- AB-001 or another phase would begin without separately accepted authority.

## Next phase

AB-001 may begin only after the unfinished native Codex controller work reaches a durable verified state and Earl separately authorizes controlled CodexPro-to-Astral Bridge source migration and rebrand.

This AGENTS consolidation task changes governance documents only. It does not authorize AB-001, source migration, runtime wiring, or deployment.
