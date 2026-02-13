## Task Management

### PRD Workflow

1. **Create PRD** — Generate a Product Requirements Document from a feature description. Ask clarifying questions before writing. Save as `tasks/prd-<feature-name>.md`.
2. **Generate Tasks** — Break the PRD into a phased task list with Goals, Files, Estimates, Dependencies, and Verification criteria per task. Save as `tasks/tasks-<prd-name>.md`.
3. **Process Tasks** — Implement one sub-task at a time. Ask for permission before proceeding to the next sub-task.

### Approval Gate

**Before any write, edit, or execute action:**
1. Present a clear plan showing what will be done and why.
2. Wait for explicit user approval before proceeding.
3. Read-only operations (searching, reading files, analyzing) do not need approval.

This applies to: creating files, modifying code, running build/test commands, installing packages, git operations.

### Incremental Execution

- Implement ONE sub-task at a time — never the entire plan at once.
- After each sub-task, validate before moving on:
  - Run type checker if applicable
  - Run linter
  - Run relevant tests
- Only proceed to the next sub-task when the current one is verified green.

### Stop-on-Failure Protocol

When a test, build, or type check fails:
1. **STOP** — do not proceed to the next step.
2. **Report** the failure clearly (what failed, error message, file and line if available).
3. **Propose** a specific fix with reasoning.
4. **Wait for approval** before applying the fix.
5. **Fix**, re-run validation, confirm green.

NEVER auto-fix silently. NEVER apply multiple speculative fixes at once.

### Task Completion Protocol

1. When a sub-task is finished, mark it as completed (`[x]`).
2. Validate: run type check + lint + relevant tests. All must pass.
3. When ALL sub-tasks under a parent task are completed:
   - Run the full test suite.
   - Only if all tests pass: stage changes.
   - Clean up temporary files and temporary code.
   - Commit with a descriptive commit message.
4. Mark the parent task as completed only after all sub-tasks are done and committed.

### Task List Maintenance

- Update the task list as work progresses.
- Add new tasks as they emerge during implementation.
- Keep the "Relevant Files" section accurate and up to date.
- Before starting work, check which sub-task is next.
