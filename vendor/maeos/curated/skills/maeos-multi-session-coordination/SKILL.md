# MAEOS multi-session coordination

Before related parallel work, use repository evidence to map active branches, worktrees, writers, shared files, and dependencies. One writer owns one repository/worktree. Do not infer ownership from recency, and do not create a new thread, worktree, or worker without root authorization.
