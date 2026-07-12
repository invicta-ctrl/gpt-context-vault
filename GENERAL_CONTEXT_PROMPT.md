# Context Update Prompt

Review the current conversation and identify only information suitable for persistent storage.

Classify each candidate as:

- stable;
- active;
- temporary;
- superseded; or
- archived.

Do not store speculation, temporary emotions, credentials, secrets, unnecessary sensitive information, repetitive history, or unresolved ideas.

Check existing context for conflicts. Apply the source-of-truth hierarchy and identify anything that would be superseded.

Prepare exact minimal changes for the relevant files and update any required indexes or changelogs.

Do not modify the repository until the proposed update has been reviewed and approved.
