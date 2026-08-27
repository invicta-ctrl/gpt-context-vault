---
schema_version: 1
status: active
scope: astral-bridge-project-extension
extension_id: ASTRAL-BRIDGE-PROJECT-POLICY-V1
target_repository: invicta-ctrl/Astral-Bridge
universal_governance: ..\AGENTS.md
last_reviewed: 2026-08-28
---

# Astral Bridge Project Policy Extension

Read the byte-identical universal root `AGENTS.md` first. This extension preserves Astral Bridge-specific product, protected-source, security, verification, and phase-boundary rules.

## Sol Advisor inheritance

Inherit `SOL-ADVISOR-GLOBAL-001` without weakening Astral Bridge protected-source, connector, privacy, recovery, or external-state safeguards. Sol / High selects `solo|delegate|audit|full`; Ox is temporary implementation-only and fail-closed; Luna / Max and Terra / High are the native implementation lanes; fresh Sol / High alone reviews audit/full work.

## Scope

This extension governs the entire Astral Bridge repository.

Do not add nested `AGENTS.md` files. Repository-specific rules belong here unless a later accepted specification explicitly authorizes a narrower extension.

The universal root `AGENTS.md` is a managed replica and must not be independently rewritten. Project-specific policy changes belong in this file or an accepted project specification.

## Authority order

Within Astral Bridge:

1. Earl's current explicit instruction.
2. The active accepted specification named by `.codex/CURRENT.md`, including approved amendments.
3. The universal root policy, this extension, and verified repository state.
4. Current official tooling conventions where the active task depends on them.
5. Historical notes only when provenance or migration requires them.

Never invent missing authority. Stop on a material contradiction that cannot be resolved safely.

## Active work pointer

Before non-trivial work, read `.codex/CURRENT.md` and only the accepted specification, checkpoint, and bounded source/test files it names.

Work on one accepted task or vertical slice at a time. Do not start a future phase automatically.

## Phase state

AB-000 repository bootstrap is closed and remains preserved as historical authority.

AB-001 is the controlled runtime-migration and native-identity phase. Its accepted specification is:

```text
.codex/specs/accepted/2026-08-21-astral-bridge-ab001-runtime-migration-and-native-identity.md
```

AB-001 has established a self-contained Astral-native local runtime in this repository. Exact source, migration, identity, runtime, and security evidence lives in `.codex/` manifests and checkpoints.

AB-001 does not authorize AB-002, Cloudflare relay work, Tokscale, dashboards, remote command transport, deterministic installation, update/uninstall, public release, or paid-model dependencies.

## Canonical locations

```text
Product: Astral Bridge
Machine identifier: astral-bridge
Local repository: D:\Documents\Codex\Astral-Bridge
Canonical GitHub repository: https://github.com/invicta-ctrl/Astral-Bridge
Protected legacy source: C:\Users\adria\CodexTools\CodexProSource
```

The protected legacy source is provenance and rollback evidence. Treat it as read-only during Astral work. Do not edit, reset, clean, stash, branch-switch, commit, push, reconfigure, or delete from it.

Astral Bridge must remain self-contained and must not import or execute runtime code from the protected checkout.

## Product identifiers

Use these active identifiers consistently:

```text
Product: Astral Bridge
Package/machine id: astral-bridge
Namespace: astral
Plugin: astral-bridge
Main skill: astral-bridge
Installer skill: astral-install
CLI: astral
Environment prefix: ASTRAL_BRIDGE_
Configuration directory: .astral-bridge
Primary error identity: AstralBridgeError
```

CodexPro references are allowed only for accurate history, provenance, migration evidence, or explicit legacy-reference tests. They must not reappear in active runtime identity.

## Repository and plugin shape

Keep one simple repository with ordinary root-level runtime structure such as:

```text
src/
scripts/
package.json
package-lock.json
docs/
plugins/
installer/
.codex/
.agents/
```

Do not create an unnecessary monorepo without accepted authority.

The repository now contains the real local MCP runtime. The Codex plugin remains skills-only in AB-001; it does not embed `.mcp.json`, `mcpServers`, or app wiring. Runtime launch and client configuration remain explicit local operations.

## Security and secrets

Astral Bridge has significant local-machine capabilities. Preserve or strengthen:

- least privilege and explicit allowed roots;
- blocked secret/config/key paths;
- path traversal and symlink-aware checks;
- authentication and loopback/no-auth restrictions;
- tool, write, bash, and controller modes;
- bounded reads, search, imports, commands, and outputs;
- command restrictions and destructive-operation controls;
- controller permissions, approvals, protected roots, writer locks, and clean thread ownership;
- no implicit credential collection;
- no credential commits or secret logging.

Never print or commit authentication values, passwords, private keys, session material, credential files, recovery material, or private provider identifiers.

The local runtime must not require a hosted LLM/API key. Controller mode must remain optional.

## Git safety

Preserve unknown work and remote history.

- Verify root, branch, `HEAD`, upstream, ahead/behind, status, accepted authority, and writer state before mutation.
- Never force-push or rewrite remote history without explicit accepted authority.
- Never reset, clean, stash, discard, or overwrite unknown work.
- Review the complete logical diff before committing.
- Commit only accepted scope.
- Verify commit and push claims directly.
- Recheck the protected legacy checkout before migration-sensitive closure claims.

## Verification

AB-002 closure verification includes:

```text
npm run build
npm run resilience:smoke
npm run control:git
npm run control:process
npm run control:smoke
npm run runtime:security
npm run identity:smoke
npm run smoke
npm run stress
node scripts/verify-scaffold.mjs
git diff --check
```

Run the smallest focused checks during implementation and the accepted closure set before claiming completion. Do not weaken a verifier merely to make it green.

Before AB-002 closure, confirm:

- `.codex/CURRENT.md` points to the accepted AB-002 authority or verified closure state;
- the repository-native Astral HTTP connector is the live ChatGPT-facing runtime;
- safe Git mutation, managed-process, recovery, identity, and workspace-persistence controls pass real ChatGPT Web dogfood;
- Astral does not start, resume, continue, steer, approve, or review billable Codex/model work;
- deterministic security evidence records zero real Codex/model calls;
- the protected legacy checkout remains clean and read-only;
- the external connector rollback backup remains available without copying credentials into Git;
- no credential, cache, generated junk, controller registry, `.ai-bridge`, `.astral-bridge`, `.claude`, or unrelated work is staged;
- remaining CodexPro references are intentionally historical, provenance, compatibility, or deliberate legacy-test residue;
- Cloudflare feature work, installer/updater work, public release, and AB-003 implementation have not been introduced;
- the complete logical and staged diffs have been reviewed.

## Stop conditions

Stop rather than improvise when:

- repository identity differs from `invicta-ctrl/Astral-Bridge`;
- authority, current pointer, migration source, or expected baseline is missing or contradictory;
- the Astral worktree has unknown dirty work or an active conflicting writer;
- the protected legacy source changes unexpectedly during migration-sensitive work;
- implementation would overwrite unknown work or require destructive Git history changes;
- source licensing/provenance cannot be preserved;
- credentials or private machine/session state are found in proposed material;
- a security, rollback, recovery, or protected-source boundary cannot be preserved or verified;
- the runtime would depend on the protected legacy checkout or a paid model/API;
- the task requires AB-003, Cloudflare feature work, Tokscale, installer/update/publication work, or another later phase without separate accepted authority;
- public-release restrictions conflict with a proposed action.

## Next phase

AB-002 is closed only when its accepted closure checkpoint, full verification set, safe Git push, remote parity, and durable recovery evidence are complete. **AB-003 — Installer + Reliable Local Service is NOT STARTED** and requires a separate accepted specification and owner authorization.
