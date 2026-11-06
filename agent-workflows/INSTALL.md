# Installation and maintenance

This package is a reviewable distribution record. No installation script runs automatically. Explicit owner approval and a source/license review are required before any new third-party skill installation.

## Install to local hosts

1. Read the current canonical Context Vault `AGENTS.md`, accepted project spec and `manifest.json`. Verify the installed skill does not conflict with them.
2. Retrieve the three ECC skills from **`ecc-universal@2.2.3`**, using the paths in `manifest.json`. Verify SHA-256 for every required file before installation. Preserve the upstream ECC MIT license and copyright notice (`Copyright (c) 2026 Affaan Mustafa`) with any redistributed ECC copies; source: https://github.com/affaan-m/ECC/blob/v2.2.3/LICENSE. Do not use an unpinned `npx` version or run the ECC all-component installer.
3. Copy the two custom `skills/*` directories from this reviewed commit. Verify their SHA-256 after checkout.
4. Install only into new, exact user directories (no overwrites):
   - Claude Code: `%USERPROFILE%\.claude\skills\<skill-name>\SKILL.md`
   - Codex: `%USERPROFILE%\.agents\skills\<skill-name>\SKILL.md`
   - ECC supporting file from `skills/security-review/cloud-infrastructure-security.md` must also be copied to `%USERPROFILE%\.claude\skills\security-review\cloud-infrastructure-security.md` and `%USERPROFILE%\.agents\skills\security-review\cloud-infrastructure-security.md` with the manifest hash.
5. Keep `%USERPROFILE%\.codex\AGENTS.md`, `%USERPROFILE%\.claude\settings.json`, existing plugin manifests and hooks unchanged. A policy change needs a separately reviewed canonical Context Vault amendment and managed synchronization.
6. In ChatGPT Web, use the separately installed `earl-agent-workflow` routing skill where available. Files copied to Windows do not synchronize into Web automatically.
7. Astral Bridge's REA tools require their own authentication and operation approvals; a connected MCP is not proof that every provider is available.

## Verification and rollback

- Confirm all five SKILL.md frontmatter names and hashes match the manifest; compare the `security-review` supporting file and preserve the required third-party license notice.
- Verify tool discovery in a fresh session and a bounded read-only workflow. Record skipped or unrun checks.
- If an install fails, preserve existing skills and settings; remove only files created by this installation after their exact paths and ownership are confirmed.
- Updates require a reviewed package bump and diff. Never silently install new ECC hooks, GateGuard or executing reverse-engineering steps.
