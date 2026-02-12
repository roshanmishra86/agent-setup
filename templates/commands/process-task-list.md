# Task List Management

Guidelines for managing task lists in markdown files to track progress on completing a PRD.

## Task Implementation

- **One sub-task at a time:** Do NOT start the next sub-task until you ask the user for permission and they confirm.
- **Completion protocol:**
  1. When a **sub-task** is finished, immediately mark it as completed (`[ ]` → `[x]`).
  2. If **all** sub-tasks under a parent task are now `[x]`:
     - Run the full test suite.
     - Only if all tests pass: stage changes.
     - Clean up temporary files and temporary code before committing.
     - Commit with a descriptive message using the project's commit format.
  3. Mark the **parent task** as completed once all sub-tasks are done and committed.
- Stop after each sub-task and wait for the user's go-ahead.

## Task List Maintenance

1. **Update the task list as you work:**
   - Mark tasks and sub-tasks as completed per the protocol above.
   - Add new tasks as they emerge.
2. **Maintain the "Relevant Files" section:**
   - List every file created or modified.
   - Give each file a one-line description of its purpose.

## Instructions

When working with task lists:

1. Regularly update the task list file after finishing any significant work.
2. Follow the completion protocol for marking sub-tasks and parent tasks.
3. Add newly discovered tasks.
4. Keep "Relevant Files" accurate and up to date.
5. Before starting work, check which sub-task is next.
6. After implementing a sub-task, update the file and pause for user approval.
