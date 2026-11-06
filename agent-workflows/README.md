# ECC + LeanREA shared workflow (review candidate)

Status: **proposed**. This directory does not activate account-wide policy until reviewed and merged through the existing Context Vault governance path.

## Purpose

Reuse five on-demand skills in Earl's Claude Code and Codex installations while keeping accepted specifications, project `AGENTS.md`, the Context Vault canonical policy, and tool permissions authoritative. ChatGPT Web uses the separate `earl-agent-workflow` personal routing skill when available. Astral Bridge remains an evidence/tool gateway, not a policy override.

| Skill | Origin | Use |
| --- | --- | --- |
| `contract-first` | ECC 2.2.3 | Shared API, event and data contracts |
| `frontend-a11y` | ECC 2.2.3 | Form, keyboard, focus and accessible UI |
| `security-review` | ECC 2.2.3 | Authentication, payments, secrets and sensitive endpoints |
| `lean-verification` | Custom, included here | Exact-head, diff-first, risk-based review evidence |
| `leanrea-scout` | Custom, included here | Authorized read-only static reconnaissance, with gated REA escalation |

Vendor sources are **pinned, not vendored**: see `manifest.json`. Upstream ECC content is MIT licensed; retain the original [LICENSE](https://github.com/affaan-m/ECC/blob/v2.2.3/LICENSE) and attribution when redistributing copied vendor files. The two custom skill definitions live under `skills/`. Do not install the entire ECC framework or ECC PR #3869's unmodified reconnaissance implementation.

## Authority and permissions

1. Current explicit owner instructions.
2. Accepted project specification and approved amendments.
3. The authoritative project's policy and verified repository state.
4. Active Context Vault governance.
5. Context, memory and archived history only as needed.

Skills provide task guidance, not permission to write, run a binary, change a database, create a branch, merge, deploy, spend credits or bypass an REA/provider gate. Preserve managed AGENTS replicas; general policy changes use the canonical synchronization procedure.

## Host coverage

- **Claude Code:** User-level `%USERPROFILE%\.claude\skills\` verified in the owner's Windows environment.
- **Codex:** User-level `%USERPROFILE%\.agents\skills\` verified; existing managed `%USERPROFILE%\.codex\AGENTS.md` left unchanged. The same `lean-verification` checklist is installed in both hosts, but its current frontmatter names Claude Code; fresh-session Codex automatic discovery/selection has not been proven.
- **ChatGPT Web:** The separate personal `earl-agent-workflow` routing skill has been saved. It does not imply all five Windows skills execute in ChatGPT Web.
- **Astral Bridge:** Use existing authenticated tools and project-specific governance. This package does not modify the MCP server, add an unrestricted tool, or certify provider readiness.

Use `INSTALL.md` for review and updating. The dated `CHECKPOINT_2026-11-06.md` records the unfinished independent Context Vault MAEOS worktree; it is not acceptance evidence.

## Acceptance for promotion

- Review all skill descriptions and custom instructions against canonical AGENTS and project policies.
- Verify exact vendor package/version/hash and custom file hashes.
- Confirm the five skills are discovered in fresh authorized Claude Code and Codex sessions without new hooks.
- Validate a read-only LeanREA Scout example without executing a target; verify denied provider actions stay denied.
- Do not change global AGENTS/managed replicas or deploy Astral Bridge through this PR.
- Keep this PR unmerged until independent review and the active governance work have been reconciled.
