# Instruction refinement standard

## Purpose

Natural instructions are valid input. They are not automatically valid
implementation prompts. The refinement gate preserves the user's wording,
adds only authoritative context, and produces an inspectable execution brief
before model selection or edits begin.

## Input classification

Classify the original input as exactly one of:

- `rough_instruction`: the outcome, target, behavior, boundary, or completion
  condition is materially unclear.
- `partial_task`: the goal is understandable but important scope,
  constraints, acceptance, or verification details are missing.
- `complete_prompt`: goal, authority, scope, constraints, acceptance,
  verification, and documentation expectations are already sufficient.
- `precise_command`: a small, reversible, named action with an obvious
  completion condition.

Do not inflate a complete prompt or precise command. A rough or partial input
must never be sent directly to an implementation worker.

## Refinement procedure

1. Preserve the original input verbatim in transient runtime metadata.
2. Read the minimum authoritative project files needed for the task.
3. Retrieve relevant durable preferences from this vault only when they affect
   the work.
4. Separate verified repository facts from assumptions.
5. Add scope, non-goals, requirements, constraints, acceptance criteria,
   allowlisted verification, and documentation duties.
6. List only unresolved questions that could change correctness, safety,
   architecture, or scope.
7. Set `safe_to_route` to false when a material ambiguity or conflict remains.
8. Keep the brief proportional to the task and name sources instead of
   copying whole documents.

## Automatic continuation

Continue to routing only when the intended outcome is clear, the change is
reversible, authoritative context resolves the important details, no
destructive or external-write choice remains, confidence meets the project's
threshold, and the repository state is safe.

Stop for user input when interpretations remain materially different, the
request conflicts with authoritative project documentation, the target
repository is unknown, a migration/deployment/publication/data-integrity choice
is unresolved, required context is missing, or scope expanded substantially.

## Prompt-bloat controls

Do not repeat requirements, copy entire repository documents, add generic role
play, propose unrelated cleanup, introduce dependencies, or turn a focused
change into a repository-wide audit. Quality is measured by reliable execution,
not by brief length.

