# Generating a Task List from a PRD

## Goal

Create a detailed, step-by-step task list in Markdown format based on an existing Product Requirements Document (PRD). The task list guides a developer through implementation.

## Output

- **Format:** Markdown (`.md`)
- **Location:** `/tasks/`
- **Filename:** `tasks-[prd-file-name].md`

## Process

1. **Receive PRD Reference:** The user points to a specific PRD file.
2. **Analyze PRD:** Read and analyze the functional requirements, user stories, and other sections.
3. **Phase 1: Generate Parent Tasks:** Create high-level tasks (~5) required to implement the feature. Present them to the user (without sub-tasks). Say: "I have generated the high-level tasks. Ready to generate the sub-tasks? Respond with 'Go' to proceed."
4. **Wait for Confirmation:** Pause and wait for the user to respond with "Go".
5. **Phase 2: Generate Sub-Tasks:** Break down each parent task into smaller, actionable sub-tasks.
6. **Identify Relevant Files:** List potential files that will need to be created or modified, including test files.
7. **Generate Final Output:** Combine parent tasks, sub-tasks, relevant files, and notes into the final Markdown structure.
8. **Save Task List:** Save as `tasks-[prd-file-name].md` in `/tasks/`.

## Output Format

```markdown
## Relevant Files

- `path/to/file1.ts` - Brief description of why this file is relevant.
- `path/to/file1.test.ts` - Tests for `file1.ts`.

### Notes

- Unit tests should be placed alongside the code files they test.
- Run tests with the project's configured test runner.

## Tasks

- [ ] 1.0 Parent Task Title
  - [ ] 1.1 Sub-task description
  - [ ] 1.2 Sub-task description
- [ ] 2.0 Parent Task Title
  - [ ] 2.1 Sub-task description
- [ ] 3.0 Parent Task Title
```

## Interaction Model

The process requires a pause after generating parent tasks to get user confirmation before generating detailed sub-tasks.

## Target Audience

The primary reader is a **junior developer** who will implement the feature.
