## Task Management

### PRD Workflow

1. **Create PRD** — Generate a Product Requirements Document from a feature description. Ask clarifying questions before writing. Save as `tasks/prd-<feature-name>.md`.
2. **Generate Tasks** — Break the PRD into a task list with parent tasks and sub-tasks. Save as `tasks/tasks-<prd-name>.md`.
3. **Process Tasks** — Implement one sub-task at a time. Ask for permission before proceeding to the next sub-task.

### Task Completion Protocol

1. When a sub-task is finished, mark it as completed (`[x]`).
2. When ALL sub-tasks under a parent task are completed:
   - Run the full test suite.
   - Only if all tests pass: stage changes.
   - Clean up temporary files and temporary code.
   - Commit with a descriptive commit message.
3. Mark the parent task as completed only after all sub-tasks are done and committed.

### Task List Maintenance

- Update the task list as work progresses.
- Add new tasks as they emerge during implementation.
- Keep the "Relevant Files" section accurate and up to date.
- Before starting work, check which sub-task is next.
