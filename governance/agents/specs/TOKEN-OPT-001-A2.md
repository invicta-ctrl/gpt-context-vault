---
schema_version: 1
spec_id: TOKEN-OPT-001-A2
title: Capability Cleanup and Complementary Tool Routing
status: accepted
owner: Earl
accepted_date: 2026-08-24
timezone: Asia/Manila
risk: medium
execution_plane: Astral Bridge deterministic local operations
classification: account-wide-tool-governance-amendment
---

# TOKEN-OPT-001-A2
## Capability Cleanup and Complementary Tool Routing

## Acceptance record

Earl explicitly authorized this amendment on 2026-08-24 by directing a live cleanup of Codex and Claude skills, plugins, and MCP servers; choosing the standalone Claude Figma MCP over the Claude Figma plugin; requesting complementary routing for Serena, lean-ctx, CodeGraph, Context7, Hallmark, and Impeccable; and authorizing the exact Codex user-skill removals below.

This amendment authorizes only the bounded changes, backups, verification, and rollback evidence below. It does not authorize commits, pushes, deployments, destructive Git operations, unrelated package changes, or overlapping writes to an occupied repository worktree.

## Objective

Reduce always-on capability noise and redundant routing while retaining the strongest useful tools and assigning one deterministic owner to each class of work.

## Authorized personal Claude changes

1. Uninstall `figma@claude-plugins-official`.
2. Preserve the user-scoped standalone `figma` MCP at `https://mcp.figma.com/mcp`.
3. Remove the user-scoped `headroom` MCP registration.
4. Uninstall the local `headroom-ai` uv tool after recording its installed version and health.
5. Preserve the Impeccable plugin.
6. Preserve Serena, lean-ctx, CodeGraph, and Context7.
7. Update `C:\Users\adria\.claude\CLAUDE.md` with the routing contracts in this amendment.

## Authorized personal Codex skill removals

After a verified timestamped backup, remove only these active skill directories:

- `C:\Users\adria\.codex\skills\impl-validator`
- `C:\Users\adria\.codex\skills\awesome-claude-skills`
- `C:\Users\adria\.codex\skills\pdf`
- `C:\Users\adria\.codex\skills\agent-browser`
- `C:\Users\adria\.codex\skills\design-taste-frontend`
- `C:\Users\adria\.codex\skills\web-design-guidelines`
- `C:\Users\adria\.codex\skills\grill-me`
- `C:\Users\adria\.codex\skills\define-goal`
- `C:\Users\adria\.codex\skills\create-plan`
- `C:\Users\adria\.codex\skills\migrate-to-codex`
- `C:\Users\adria\.codex\skills\netlify-deploy`
- `C:\Users\adria\.agents\skills\find-skills`

Preserve the official installed and enabled `pdf@openai-primary-runtime` plugin.

`impl-validator` is removed rather than repaired. Its function overlaps the governed complete-diff review path and the official `review-agent` skill. Its visible `>` description is evidence of an Astral Bridge folded-YAML parsing defect, not evidence that its source description is empty.

## Complementary MCP routing contract

Use one primary tool for one question. Do not ask Serena, lean-ctx, and CodeGraph the same repository question in parallel.

- **Context7:** current, version-specific third-party library, framework, SDK, and API documentation only. It does not inspect the local repository.
- **lean-ctx:** default for broad repository discovery, compressed file reads, large search results, large command output, and context continuity.
- **Serena:** semantic symbol lookup, references, implementations, language-server diagnostics, and precise symbol-level edits after the relevant area is known.
- **CodeGraph:** read-only cross-module architecture, caller/callee chains, change-impact analysis, and affected-test discovery when a bounded dependency question remains after targeted lean-ctx or Serena work.

Default route:

```text
known file or symbol -> Serena
broad discovery or large output -> lean-ctx
cross-module impact uncertainty -> CodeGraph
external API or library uncertainty -> Context7
```

Stop after the first tool establishes the needed fact. Use a second tool only for a distinct unanswered dimension or verification.

## Hallmark and Impeccable composition

- **Hallmark owns design direction:** anti-generic structure, page archetype, visual world, macro-layout, and the initial direction contract for a greenfield surface or substantial redesign.
- **Impeccable owns execution quality:** UX critique, accessibility, responsive behavior, hierarchy, typography, motion, edge cases, performance, hardening, and bounded final polish.
- For greenfield or substantial redesign work: run Hallmark once to establish direction, implement within that direction, then run one bounded Impeccable audit/refinement pass and one confirmation pass.
- For narrow component fixes, accessibility, responsiveness, copy, motion, spacing, or production hardening: use Impeccable alone.
- Impeccable must preserve an accepted Hallmark direction unless Earl explicitly authorizes a direction change.
- Hallmark re-enters only when the structural concept itself is rejected or proven unsuitable. Do not alternate the tools in an open-ended polish loop.

## Context Vault change

The following existing file may be updated to encode the routing contracts above:

```text
protocols\CODEX_TOKEN_OPTIMIZATION_AND_CONTEXT_EFFICIENCY_RULES.md
```

No managed `AGENTS.md` replica may be edited directly for this amendment.

## Astral Bridge inventory repair authority and current stop condition

The audit confirms two Astral Bridge inventory defects:

1. every `~/.codex/plugins/cache/**/SKILL.md` entry is presented as an active plugin skill even when the plugin is merely cached, unavailable, disabled, or uninstalled;
2. folded or literal YAML frontmatter scalars such as `description: >` are parsed as the literal character `>`.

A later clean-writer implementation is authorized only in:

- `src/capabilitiesOps.ts`
- `src/workspaceOps.ts`
- `scripts/skill-precedence-smoke.mjs`
- one directly coupled inventory regression test or package script when required
- directly coupled checkpoint/documentation files

Required behavior:

- distinguish installed/enabled plugin skills from disabled, unavailable, and cached plugin skills;
- never present cached-only plugin skills as enabled;
- expose plugin id, version, and status when authoritative local metadata is available;
- parse folded and literal YAML frontmatter descriptions correctly;
- preserve current skill precedence, path safety, bounded output, and deterministic fallback behavior.

The Astral Bridge worktree is currently occupied by AB-002.7 closure work with tracked and untracked changes. This amendment does not authorize overlapping source writes while that state remains. The repair must wait for a clean writer handoff or a separately accepted active slice.

## Backups and rollback

Before any personal configuration or skill removal:

1. create `C:\Users\adria\.codex\backups\TOKEN-OPT-001-A2-<timestamp>`;
2. copy every changed personal file and every removed skill directory;
3. record original path, backup path, byte length, and SHA-256 for every file;
4. verify source and backup hashes before removal;
5. preserve the backup.

Rollback restores the backed-up files and directories, reinstalls `headroom-ai==0.34.0` only if needed, reinstalls the Claude Figma plugin only if needed, and re-adds only explicitly selected MCP registrations. Git-tracked governance changes roll back through a reviewed restoration or normal revert, never reset or history rewrite.

## Concurrent execution reconciliation

While this session was establishing its backup gate, another local cleanup process completed the authorized skill removals plus the Claude Figma-plugin and Headroom-MCP removals. The source skill directories changed after the live audit and were already absent when this session reached its removal step, so deletion was not repeated.

The concurrent process preserved a rollback snapshot at:

``text
C:\Users\adria\.codex\backups\tooling-cleanup-20260824-211254
```

This session added `sha256-manifest.json` and verified every file currently present in that snapshot. Because the original source directories had already been removed, this session cannot independently reconstruct pre-removal source-to-backup hash equality and does not claim that stronger evidence. The backup remains preserved.

The remaining Claude-governance and Context-Vault policy edits were separately backed up before mutation at:

```text
C:\Users\adria\.codex\backups\TOKEN-OPT-001-A2-20260824-214252
```

For those two files, source stability and source-to-backup SHA-256 equality were verified before editing. Post-change command evidence is stored under that backup's `state-after` directory.

## Verification

- `claude plugin list` shows Impeccable and does not show the Figma plugin.
- `claude mcp get figma` remains connected.
- `claude mcp get headroom` reports no configured server.
- `claude mcp list` still shows Serena, lean-ctx, Context7, and CodeGraph connected.
- `uv tool list` does not show `headroom-ai`.
- `codex plugin list --json` still reports `pdf@openai-primary-runtime` installed and enabled.
- Codex skill inventory no longer reports the explicitly removed user skills.
- `C:\Users\adria\.claude\CLAUDE.md` contains one non-conflicting routing contract.
- Context Vault diff is limited to this amendment and the token-efficiency protocol.
- No Astral Bridge source file changes while the AB-002.7 dirty writer state remains.
