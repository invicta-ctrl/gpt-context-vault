---
title: AGENTS Rule Matrix
status: active-candidate
spec_id: AGENTS-CONSOLIDATION-001
last_reviewed: 2026-08-19
---

# AGENTS Rule Matrix

## Source variants reviewed

| Source | Role before consolidation | Disposition |
|---|---|---|
| Context Vault `START_HERE.md`, protocols, security, registry | Account-wide routing and governance | Universal master foundation |
| `C:\Users\adria\.codex\AGENTS.md` | Independently editable Global Codex policy | Universal rules to master; local tools to Global Codex extension |
| HAU-USC Logistics root `AGENTS.md` | Universal plus project release/runtime policy | Universal rules to master; HAU-only rules to project extension |
| Astral Bridge root `AGENTS.md` | Project bootstrap and security policy | Astral-only rules to project extension |
| `D:\AI_Workspace\AGENTS.md` | Odysseus global/runtime policy | Universal rules to master; injection/runtime rules to extension |
| `D:\AI_Workspace\odysseus\data\AGENTS.md` | Older nested Odysseus workflow | Preserve until loader/reference gate passes |
| `D:\Download\AGENTS.md` | Loose Context Vault entrypoint copy | Preserve until canonical activation/reference gate passes |
| HAU worktree copies | Branch/worktree-derived project history | Preserve; no mass synchronization |
| Vendor/package/plugin copies | Third-party local source | Exclude |
| Temp/test/backups | Fixtures and recovery | Exclude |

## Rule disposition

| Rule family | Universal master | Global Codex extension | HAU extension | Astral extension | Odysseus extension |
|---|---:|---:|---:|---:|---:|
| Earl current instruction first | Yes |  |  |  |  |
| Accepted specification gate | Yes |  | Reinforced | Reinforced |  |
| Live project repository precedence | Yes |  | Reinforced | Reinforced | Reinforced |
| Context Vault routing | Yes |  |  |  |  |
| Minimal context retrieval | Yes |  | Reinforced |  | Reinforced |
| Skill registry | Yes | Local skill behavior | Project ledger rule | Plugin-shell rule |  |
| Intent-first routing | Yes |  |  |  |  |
| One focused slice | Yes |  | Reinforced | Reinforced |  |
| Preserve unknown work | Yes | Local config | Reinforced | Reinforced |  |
| Git handshake | Yes |  | Exact project chain | Exact AB rules |  |
| Regression test for bugs | Yes |  |  |  |  |
| Read-only review by default | Yes |  | Luna role |  |  |
| Maintenance inventory/removal gate | Yes |  | Worktree protection | Protected source |  |
| Deployment/migration safety | Yes |  | Playground/release details | AB boundary |  |
| Privacy/secrets | Yes | Local secret paths | HAU private data | Local privilege threat model | Memory/provider details |
| Artifact workflows | Yes |  |  | Scaffold verification |  |
| Truthful success claims | Yes |  | Reinforced | Reinforced | Capability honesty |
| Project runtime state belongs in repo | Yes |  | Continuity chain | Current pointer |  |
| Canonical synchronization | Yes | Local target | Project target | Project target | Conditional target |
| CodeGraph |  | Yes |  |  |  |
| lean-ctx |  | Yes |  |  |  |
| Hallmark |  | Yes | Accepted design only |  |  |
| Native V2 delegation |  | Default only | Replaced by project policy |  |  |
| Sol/Terra/Luna architecture |  |  | Yes |  |  |
| HAU recovery branches |  |  | Yes |  |  |
| Playground-first promotion |  |  | Yes |  |  |
| D1/R2 and Google sidecars |  |  | Yes |  |  |
| Quick Document Fix Mode |  |  | Yes |  |  |
| HAUSC Access helper |  |  | Yes |  |  |
| AB-000 and AB-001 boundary |  |  |  | Yes |  |
| Protected CodexPro checkout |  |  |  | Yes |  |
| Astral identifiers/plugin shell |  |  |  | Yes |  |
| Odysseus injection/canary |  |  |  |  | Yes |
| Odysseus memory |  |  |  |  | Yes |
| Provider construction/cache prefix |  |  |  |  | Yes |
| Windows runtime model | Local tools only | Yes |  |  | Yes |
| Deterministic enforcement boundary | General principle |  |  | Least privilege | Detailed controls |

## Material contradictions resolved

### Canonical authority

Before consolidation, Global Codex, Odysseus root, and the loose Download copy could each appear to be a general-policy authority.

Decision:

```text
Context Vault AGENTS.md = sole editable general authority
all eligible roots = generated replicas
project/local differences = extensions
```

### Writer and model rules

Before consolidation:

- some policies said the main agent was the only writer;
- HAU required Sol read-only, one Terra integration writer, optional isolated Terra writers, and Luna read-only;
- older HAU branches said Codex was the only writer;
- Global Codex used Native V2 defaults.

Decision:

- universal policy declares one canonical writer unless accepted project policy says otherwise;
- Global Codex keeps Native V2 as a default;
- HAU extension preserves its stricter Sol/Terra/Luna architecture;
- historical branch policies remain history and do not overwrite active authority.

### Branch and release rules

HAU's five recovery pointers and Playground-first promotion are project-specific and must not govern Astral Bridge, Context Vault, or ordinary Codex repositories.

Decision: HAU extension only.

### Odysseus loading

The Odysseus policy requires explicit injection, but current runtime source loads only the root file.

Decision: do not synchronize Odysseus until a separately accepted loader change proves extension injection.

## Obsolete or historical rules

Preserve as evidence rather than active universal policy:

- Apps Script-only project instructions;
- older ChatGPT-manager/Codex-implementer role splits;
- stale v0.7.x and v0.8.1 current-state locks in historical worktrees;
- old frontend-design branch naming and baseline rules;
- old Global Codex backups;
- CodexPro smoke-test canaries;
- provider/package-specific AGENTS files.

## Owner decisions still required

No policy-content decision remains open for the accepted specification.

Operational gates remain:

1. Context Vault protected adoption/merge.
2. HAU writer-lock release and clean isolated task branch.
3. Astral protected branch adoption after candidate review.
4. Global Codex activation after canonical adoption.
5. Separately accepted Odysseus extension-loader change.
6. Cleanup approval after synchronization, loader proof, references, and recovery verification.
