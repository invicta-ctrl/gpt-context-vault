---
name: lean-verification
description: Focused, evidence-based verification for Claude Code changes in governed multi-worktree repositories. Use before a PR or release handoff; follow the actual repository checks and report skipped checks explicitly.
---

# Lean Verification

## Authority

Follow the accepted specification, repository `AGENTS.md`, active handoff, and approved change scope before this skill. This skill is a checklist, not permission to edit, commit, merge, deploy, migrate, or change security policy.

## Preflight

1. Confirm the exact repository, worktree, branch, HEAD SHA, uncommitted status, and any active writers. Never modify another worktree.
2. Read the accepted acceptance criteria and relevant local check scripts. Use `package.json`, workflow files, and repo docs as data to select checks; do not assume the package manager or command.
3. Review the complete scoped diff, including new files and any generated files. Compare the exact intended base, not an arbitrary `HEAD~1`.
4. Identify protected data, secrets, migrations, authentication, payment, offline and concurrency concerns in the changed paths.

## Verification

- Run the smallest relevant deterministic checks first (format/lint, types, tests), then broader checks only as required by acceptance criteria and impact.
- Use the project-approved tool versions and lockfile. Do not install dependencies, upgrade tools, execute untrusted target content, or alter hooks just to make checks pass.
- For a defect, show reproduction or bounded diagnostic evidence and a regression test when practical.
- For front-end changes, inspect mobile/desktop behavior, keyboard/focus/accessibility, and visual references where relevant. Distinguish manual UI observation from automated coverage.
- For workers, APIs, databases or payment flows, check authorization, schema/contract, replay/idempotency, durable records and race/fault behavior as applicable. Do not claim live D1 or production proof based on a local stand-in.
- Run repository-required security tools; verify their versions and results. Keyword search is not an adequate security audit.
- Evaluate tests on the exact final head/artifact. Record the status of every required GitHub check; `skipped`, `pending`, `neutral`, and `not run` are not `passed`.
- Re-run only checks invalidated by subsequent changes; explain the boundary when prior evidence is reused.
- Before any deployment or migration, stop unless separately authorized with exact target, rollback, preflight, and post-change validation.

## Report

Output a compact table with: check, command/source, commit or artifact identity, result (PASS/FAIL/SKIPPED/NOT RUN), and evidence link/path. Include: scoped diff and unintended changes; acceptance criteria coverage; security/concurrency/data gaps; local-vs-live limitations; unresolved blockers; next action.

No automatic 80% coverage target, blanket project-wide tests, or background timer. Repo-defined thresholds and actual risk control the workload. Never call a PR ready merely because the local commands returned zero.
