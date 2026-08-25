---
schema_version: 1
status: active
scope: global-codex-local-extension
extension_id: EARL-GLOBAL-CODEX-EXT-V1
target_root: C:\Users\adria\.codex
universal_governance: ..\AGENTS.md
last_reviewed: 2026-08-25
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

## Owner-started Sol execution boundary

For every repository unless a stricter accepted project rule applies:

- Native Multi-Agent V2 is enabled with no Sol child eligibility, model-specific direct
  worker ceilings of Luna Max 16, Terra Max 2, and Ox Alpha 16, sixteen total direct
  workers, depth one, and recursive child spawning disabled. No mandatory zero-worker
  startup applies; capacity is not a staffing target.
- Unattended, background, scheduled, watchdog, ChatGPT Web, and Astral-initiated Codex
  work remains prohibited without Earl's exact authorization.
- Direct work Earl deliberately starts inside Codex Desktop is an owner-started Sol
  session. Sol governs bounded delegation and remains the top-level integrator and final
  reviewer.
- At most two writers may coexist account-wide only across proven-isolated repositories
  or worktrees; every repository/worktree has at most one writer and an explicit lock.
- Automatic fallback, silent model substitution, recursive spawning, and uncontrolled
  retry remain disabled. Fallback is a new explicit Sol routing decision.
- Sol High is the parent; Ox Alpha is the preferred backend writer and may be read-only
  when not writing; Terra Max is the explicit fallback or integration-sensitive writer;
  Luna Max is read-only; DeepSeek is disabled from active and fallback routes.
- A permit-gated CLI run still requires a fresh exact interactive permit. The scheduled
  `Earl Codex Usage Guard` preserves app-server infrastructure and blocks unpermitted
  primary `codex.exe` processes.
- Model/provider routing metadata may be inspected deterministically but never treated
  as execution authority.
- After a canonical governance change, pre-existing write-capable sessions are
  `STALE_GOVERNANCE` for new mutations until a fresh session proves A7 was loaded.

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
- verify A8 agents/concurrency/router settings, Sol-child prohibition, model-specific worker ceilings, depth-one delegation, writer caps, and DeepSeek-disabled active routes without reading or changing credential values;
- report the exact local files changed and backup path.

A request to change universal rules in `C:\Users\adria\.codex\AGENTS.md` must be redirected to the Context Vault canonical master.
