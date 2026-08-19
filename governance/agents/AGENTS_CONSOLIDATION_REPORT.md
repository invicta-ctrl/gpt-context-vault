---
title: AGENTS Consolidation Report
status: in-progress-partial
spec_id: AGENTS-CONSOLIDATION-001
updated: 2026-08-19
---

# AGENTS Consolidation Report

## Current result

The specification gate has passed and the accepted authority is durable.

Completed:

- read-only C:/D: inventory and hash analysis;
- zero-unclassified classification;
- accepted specification recorded, committed, and pushed;
- isolated Context Vault task branch/worktree;
- machine-readable pre-change inventory;
- canonical universal policy adopted into Context Vault `main` through PR #6;
- four project/local extension sources;
- deterministic registry, synchronization, and verification tooling;
- isolated Astral Bridge candidate synchronized, verified, committed, and pushed;
- LF-stable canonical and extension bytes adopted through PR #7;
- preservation of HAU, Odysseus, historical, worktree, vendor, backup, and test files.

Blocked:

- HAU synchronization is blocked by active Terra writer locks and unrelated dirty work.
- Odysseus synchronization is blocked because its current runtime loads only the root policy and has no project-extension loader.
- Live Astral activation and protected-main merge require separate repository authorization.

No deployment, database, provider, Google, credential, model, or application-runtime state has changed. Global Codex is now eligible for its targeted backup-and-activation step.

## Canonical activation evidence

```text
Context Vault adoption PR: #6 / MERGED
Context Vault adoption merge: 5718995f74c832678f421d113671fb1d1f1923cf
LF stability PR: #7 / MERGED
Active main: c9e0be299c017dadcad75addfa8048f10f679f7f
Registered canonical path: D:DocumentsCodexGitHubgpt-context-vaultAGENTS.md
Canonical SHA-256: 66554a916d7080e040332d30fb93b9441b296f805cf3a47b5c350caaaa7ce769
Canonical working-tree EOL: LF
Untracked .codegraph/: PRESERVED / UNCHANGED
```

## Current-main reconciliation

Before canonical adoption, the task branch fetched and reconciled the current remote `main` at `48ac55aa71a5442ab3e213b4041602e30019a9ed`. The reconciliation preserved the newer accepted account-wide AI-assisted SDD, incremental `.codex/CURRENT.md` routing, and context-compaction survival rules rather than replacing them with the older task-branch snapshot.

```text
candidate before reconciliation: 88bb855
current origin/main reconciled:   48ac55aa71a5442ab3e213b4041602e30019a9ed
canonical root after reconciliation SHA-256:
66554a916d7080e040332d30fb93b9441b296f805cf3a47b5c350caaaa7ce769
```

The Astral candidate was resynchronized to the reconciled canonical root, pinned to LF-stable governance bytes, reverified, committed, and pushed at `61129771b2089c43fb61a07932d103ba065fc116`. Live Astral `main` remains unchanged pending the explicit adoption decision.

## Branches

### Context Vault

```text
branch: governance/agents-consolidation-001
base: edaadec29c6b83472c079844c18e94890a7f7742
specification commit: c21ecff
current-main reconciliation commit: 5e264b1f34a5e548d179a403c7420e625a93e64d
adoption PR #6 merge: 5718995f74c832678f421d113671fb1d1f1923cf
LF-stability PR #7 merge: c9e0be299c017dadcad75addfa8048f10f679f7f
active branch: main
active canonical SHA-256: 66554a916d7080e040332d30fb93b9441b296f805cf3a47b5c350caaaa7ce769
```

The registered local checkout now tracks adopted `main`. The previous feature commit remains preserved on its branch and remote; the untracked `.codegraph/` directory remains untouched.

### Astral Bridge

```text
branch: governance/agents-consolidation-001
base: 75aab9d6ea3b8921307f080e7a939f31e69f0f51
candidate commit: 61129771b2089c43fb61a07932d103ba065fc116
```

The main checkout remains unchanged. The candidate branch was pushed but was not merged.

## Managed-target state

| Target | Replica | Extension | State |
|---|---|---|---|
| Context Vault | Active canonical `main` | N/A | Adopted; local path and SHA verified |
| Global Codex | Unchanged | Source prepared | Eligible; backup and activation pending |
| HAU-USC Logistics | Unchanged | Source prepared only | Blocked |
| Astral Bridge | `MATCH` on candidate branch | `MATCH` on candidate branch | Verified and pushed; live main blocked |
| Odysseus | Unchanged | Source prepared only | Blocked |

## Candidate execution evidence

```text
Astral current-main resynchronization dry run: PASS (root WOULD_UPDATE; extension MATCH)
Astral root synchronization: UPDATED
Astral extension synchronization: MATCH / unchanged
Astral root SHA-256: 66554a916d7080e040332d30fb93b9441b296f805cf3a47b5c350caaaa7ce769
Astral extension SHA-256: a87fb95c76a0097dea21eb7a1b77e766cd38af12cf01d1f07f516e902942644e
Astral targeted verification: PASS
Astral git diff --check: PASS
Astral scripts/verify-scaffold.mjs: PASS
Astral commit/push: 61129771b2089c43fb61a07932d103ba065fc116 / PASS
Astral LF attributes: PASS (`AGENTS.md` and extension forced to LF)
Astral upstream divergence: 0 ahead / 0 behind
Astral merge: AWAITING EXPLICIT ADOPTION DECISION; NOT PERFORMED
```

## Stale-reference audit

The final bounded deterministic scan covered 718 owned/governance files and produced 15 raw matches. The detailed disposition is maintained in `governance/agents/AGENTS_AUDIT.md`.

- **Three actionable references remain blocked:** the literal `REQUIRED_MODEL: CODEX` fields in HAU `.codex/CURRENT.md` and `.codex/CURRENT_TASK.md`, plus the Odysseus root claim that it is the canonical global policy.
- **Five HAU policy/test references are intentional safeguards:** they state or test that the legacy model metadata is superseded and therefore remain unchanged.
- **Seven Context Vault matches are intentional provenance:** inventory, disposition, and consolidation evidence.
- **No automatic stale-reference rewrite was performed.** HAU remains blocked by writer locks and dirty work; Odysseus remains blocked by missing extension-loading proof.
## Final governance verification modes

```text
PowerShell parser: PASS for sync-agents.ps1 and verify-agents.ps1
Context Vault git diff --check: PASS
Full synchronization dry run: PASS
Candidate verification: PASS
  astral-bridge root: MATCH
  astral-bridge extension: MATCH
  global-codex: BLOCKED
  hau-usc-logistics: BLOCKED
  odysseus: BLOCKED
Strict required-target verification: EXPECTED FAIL
Strict exit code: 1
Strict blocking result count: 3
```

The strict failure is the correct safety result. It proves that the package does not treat a prepared candidate as full live activation and does not bypass Global Codex, HAU, or Odysseus gates. Astral live `main` also remains blocked because no merge was authorized.
## Final filename-only verification

```text
PRE-CHANGE EXACT WINDOWS-EQUIVALENT AGENTS.md: 106
CANDIDATE-STATE EXACT WINDOWS-EQUIVALENT AGENTS.md: 108
CHANGE: +2 isolated candidate-worktree files only
EXACT UPPERCASE AT CANDIDATE STATE: 100
CASE VARIANTS: 8
UNIQUE SHA-256 HASHES: 42
DUPLICATE HASH GROUPS: 11
AGENTS-FAMILY VARIANTS: 18
UNCLASSIFIED: 0
INACCESSIBLE PROTECTED PATHS: 206
```

The two added exact files are the Context Vault canonical candidate and the Astral Bridge managed-replica candidate. The final scan did not discover an unclassified exact file.

## Cleanup

No stale, historical, worktree, backup, fixture, package, plugin, marketplace, or vendor file has been removed or archived.

Cleanup remains gated by:

```text
canonical activation
-> eligible replica synchronization
-> extension loading proof
-> reference audit
-> recovery verification
-> owner-approved final cleanup
```

## Completion boundary

This report must not claim full consolidation while a required target remains blocked. The accepted architecture and tools are prepared, but live activation remains partial.
