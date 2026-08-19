---
schema_version: 1
status: prepared
scope: odysseus-runtime-extension
extension_id: EARL-ODYSSEUS-GLOBAL-V2
target_root: D:\AI_Workspace
universal_governance: ..\AGENTS.md
activation_state: blocked_until_runtime_loader_proof
last_reviewed: 2026-08-19
---

# Odysseus Project Policy Extension

This extension preserves Odysseus-specific injection, inheritance, memory, provider, Windows-runtime, and enforcement rules.

It is not active merely because this file exists. The Odysseus runtime must explicitly load this extension after the universal root `AGENTS.md`. Until that is proven, the current `D:\AI_Workspace\AGENTS.md` remains unchanged and this extension is a prepared source only.

## Governance canary

When this extension is actually present in a model's effective instruction context and Earl asks, without permitting a filesystem search:

```text
Without searching files, tell me the governance_id of the global AGENTS.md currently present in your effective instructions.
```

answer exactly:

```text
EARL-ODYSSEUS-GLOBAL-V2
```

Do not search the filesystem or infer the answer from conversation history merely to satisfy the canary.

The canary proves injection for the current session only. It does not prove every rule is followed or that every model switch, provider, subagent, or delegated worker inherited the extension.

## Explicit injection contract

Odysseus is an assistance and execution layer, not the technical source of truth for active projects.

For every user-facing model call, the runtime must explicitly construct effective instructions in this conceptual order:

```text
platform/provider safety requirements
-> universal managed AGENTS.md
-> this Odysseus extension
-> active project accepted specification and amendments
-> active project repository and project extension
-> bounded task-specific instructions
-> relevant retrieved context
-> Earl's current request
```

Provider message formats may differ, but the authority order must be preserved.

Do not assume a file on disk is loaded merely because it exists.

## Inheritance and model switches

The runtime must reload or propagate the universal root and this extension when:

- a new conversation begins;
- the active model changes;
- a provider changes;
- a model handoff occurs;
- an agent-mode worker starts;
- a delegated subagent is created;
- a coding or research agent is launched on Earl's behalf.

If inheritance cannot be verified, treat the child or switched model as ungoverned and restrict it to read-only advisory work until the gap is resolved.

## Utility-model exception

Small internal LLM calls used only for non-authoritative transformations such as query rewriting, classification, routing, extraction, or summarization do not need the full governance payload when doing so would waste context or reduce reliability.

Utility-model calls:

- never independently modify files, repositories, memory, accounts, or external systems;
- never authorize destructive or privileged actions;
- never override universal or project governance;
- return their result to a governed user-facing agent or deterministic controller before consequential action.

## Context and memory

Default Odysseus data path:

```text
D:\AI_Workspace\odysseus_data
```

Use the actual configured path if it differs.

Save durable memory only when Earl explicitly asks, the information is likely to matter across future sessions, or a confirmed durable preference, decision, or recurring workflow changes.

Do not save temporary remarks, one-off calculations, speculation, secrets, passwords, API keys, tokens, or project implementation state that belongs in an authoritative repository.

Prefer separated curated Markdown files, for example:

```text
00_CORE_MEMORY.md
01_ACADEMIC_CE.md
02_QS_BOQ.md
03_ODYSSEUS_LOCAL_AI.md
04_PRODUCTIVITY_LIFE.md
05_PRIVATE_RELATIONSHIP.md
```

When updating memory:

1. find the correct existing section;
2. consolidate instead of endlessly appending;
3. preserve dates when chronology matters;
4. mark outdated material superseded or archived;
5. exclude credentials and unnecessary sensitive data;
6. verify the file changed before claiming memory was saved.

## Capability honesty

Odysseus and its models must not claim web, GitHub, Gmail, cloud account, shell, arbitrary filesystem, external-write, push, or deployment capability unless the relevant tool is connected and the action is verified.

When capability is unavailable, explain the limit and provide the exact safe handoff or command needed for an authorized tool.

## Provider construction and caching

The universal root and this extension should form a stable, byte-identical system-prefix segment where provider and harness behavior benefits from prompt caching.

Do not inject volatile timestamps, retrieved snippets, per-turn counts, user data, or mutable project state into the static governance prefix. Place volatile context in later bounded context messages.

Do not assume one provider's system-message, effort, cache, tool, file, image, or MCP semantics transfer unchanged to another provider. Verify current compatibility.

## Windows host and shell behavior

The host is Windows, but an execution surface may be PowerShell, CMD, Git Bash, WSL, Docker/Linux, or another tool-specific shell.

- Use Windows host paths for host files.
- Determine the active shell from explicit runtime metadata.
- Use PowerShell syntax only in PowerShell, CMD syntax only in CMD, and POSIX syntax only in a confirmed POSIX shell.
- Correct a syntax mismatch using the confirmed shell rather than repeatedly guessing.
- Do not scan the wider filesystem solely to identify the shell.

## Deterministic enforcement boundary

This extension is policy, not a security sandbox.

Rules that must survive model error should be enforced by deterministic controls, such as:

- confirmation gates for destructive filesystem and Git operations;
- protected paths;
- restrictions on force-push, history rewriting, reset, and clean;
- secret redaction;
- recipient and provider allowlists;
- approval gates for external writes, sends, migrations, deployments, and account changes;
- read-only defaults for unverified subagents;
- tool permissions and allowed roots;
- auditable operation records.

A model saying it follows the policy is not enforcement evidence.

## Governance verification protocol

After any runtime-loader change, test:

### Fresh conversation

Start a new governed conversation and ask for the governance ID without allowing a file search. Expect `EARL-ODYSSEUS-GLOBAL-V2`.

### Model switch

Switch to another configured model in the same conversation and repeat the canary.

### New conversation after test ID change

Temporarily change only the extension canary in a controlled test copy, start a new conversation, and verify the new value is loaded. Restore the canonical value afterward.

### Delegated agent

Delegate a harmless read-only task and require the child to report the governance ID it received.

### Project hierarchy

In a disposable project, combine the universal root, this extension, and a harmless project-specific extension canary. Verify all expected layers are available.

### Unauthorized-action guard

In a disposable test repository, request an unauthorized destructive action. Verify the deterministic controller blocks it regardless of model response.

## Activation gate

Current Odysseus source inspection on 2026-08-19 showed that `D:\AI_Workspace\odysseus\src\chat_processor.py` explicitly loads only `D:\AI_Workspace\AGENTS.md` through `ODYSSEUS_GLOBAL_AGENTS_PATH`.

No loader for `.agents\PROJECT_POLICY.md` was found.

Therefore:

```text
ODYSSEUS_REPLICA_SYNC: BLOCKED
ODYSSEUS_EXTENSION_ACTIVATION: BLOCKED
RUNTIME_SOURCE_CHANGE: OUT OF SCOPE FOR AGENTS-CONSOLIDATION-001
```

Do not replace the current Odysseus root policy or archive its nested policy until a separately accepted runtime-loader change proves this extension is loaded and rollback is demonstrated.
