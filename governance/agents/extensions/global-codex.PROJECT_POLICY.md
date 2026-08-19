---
schema_version: 1
status: active
scope: global-codex-local-extension
extension_id: EARL-GLOBAL-CODEX-EXT-V1
target_root: C:\Users\adria\.codex
universal_governance: ..\AGENTS.md
last_reviewed: 2026-08-19
---

# Global Codex Project Policy Extension

Read the byte-identical universal `AGENTS.md` first. This file adds only local Codex, host, skill, and tooling rules. A repository's own project extension and accepted specification override these defaults within that repository.

## Local execution boundary

- The host is Windows. Confirm the active shell from tool/runtime metadata before choosing syntax.
- Use Windows host paths for local files.
- Do not probe the wider filesystem merely to determine the shell when the runtime already identifies it.
- Preserve unknown local files, configuration, credentials, and tool state.
- Do not reconfigure models, providers, connectors, plugins, or credentials unless exact accepted scope requires it.
- Do not assume local tools, MCP servers, browser automation, or account access are available until verified.

## Default Native V2 delegation boundary

For repositories without a stricter accepted project model policy:

- The primary agent owns coordination, integration, review, and final evidence.
- Delegate only bounded, independent workstreams when delegation materially improves speed, specialization, or context isolation.
- Give each workstream an exact objective, scope, exclusions, deliverable, verification, and stop condition.
- Assign non-overlapping responsibility and file ownership.
- Never allow concurrent writers to the same file, branch area, registry, lockfile, migration, release record, or external resource.
- Native Multi-Agent V2 owns scheduling, lifecycle, concurrency, and runtime model metadata. Do not duplicate those mechanisms in prompts.
- Inspect delegated evidence and changes before integration.
- Keep sensitive, destructive, migration, deployment, external, and unresolved authorization decisions with the primary agent and Earl.
- A project extension may replace these defaults with stricter named model classes, writer locks, or delegation rules.

## CodeGraph

When a repository root contains `.codegraph/`, use CodeGraph before broad grep/find or whole-file reading for code-location, symbol, reference, call-path, and impact questions.

Preferred paths:

```text
MCP: codegraph_explore
Shell: codegraph explore "<symbol names or question>"
```

Name the relevant symbol or file and keep output bounded. If `.codegraph/` is absent, skip CodeGraph rather than indexing automatically.

## lean-ctx

Prefer lean-ctx tools when available for large shell output, file reads, and searches:

```text
ctx_shell
ctx_read
ctx_search
C:\Users\adria\.cargo\bin\lean-ctx.exe
```

Full local policy:

```text
C:\Users\adria\.codex\LEAN-CTX.md
```

Compression must not remove load-bearing errors, exit codes, failed assertions, security findings, migrations, or exact acceptance evidence. Use native tools when lean-ctx is unavailable or when uncompressed output is required for verification.

## Hallmark

For frontend, landing-page, UI, redesign, visual-audit, or design-study tasks, use the installed Hallmark skill when it directly matches accepted scope.

Hallmark does not authorize backend, infrastructure, data, migration, provider, or unrelated behavior changes. Preserve repository architecture, routes, workflow semantics, accessibility, existing content intent, project governance, and accepted design authority.

## Installed skills and plugins

- Scan currently available descriptions rather than assuming an installation from memory.
- Use the smallest directly relevant set.
- Do not invoke every skill merely because it exists.
- Do not install or update a third-party skill or plugin without explicit authorization and review.
- Preserve project-specific skill restrictions and generated-file pipelines.
- Local tool instructions never override a project's accepted specification or writer lock.

## Local helper paths

Treat local executable and helper paths as configuration, not account-wide product truth. Verify existence before use and never expose credentials or secret-bearing output.

Do not move the HAUSC Cloudflare Access helper into general policy. Its use and privacy boundary belong in the HAU-USC Logistics project extension.

## Verification

After changing this extension:

- confirm the universal root replica still matches the canonical master;
- confirm this file remains the only registered local Codex extension;
- run the canonical AGENTS verification script;
- verify no model/provider/credential configuration changed;
- report the exact local files changed and backup path.

A request to change universal rules in `C:\Users\adria\.codex\AGENTS.md` must be redirected to the Context Vault canonical master.
