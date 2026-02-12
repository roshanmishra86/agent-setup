## Version Control

### Commits

{{#COMMIT_CONVENTIONAL}}
- Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) format for all commit messages (e.g., `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`).
{{/COMMIT_CONVENTIONAL}}
{{#COMMIT_SIMPLE}}
- Write clear, descriptive commit messages that summarize the change in imperative mood (e.g., "Add user authentication", "Fix pagination bug").
{{/COMMIT_SIMPLE}}
{{#COMMIT_GITMOJI}}
- Use [Gitmoji](https://gitmoji.dev/) format for commit messages (e.g., `:sparkles: Add feature`, `:bug: Fix issue`).
{{/COMMIT_GITMOJI}}
- Commit frequently throughout the development process, even if high-level tasks are not yet complete.
- Track all non-trivial changes in git.
- Do not refer to AI assistants or AI companies in commit messages.

### Branching

- When starting work without a clear branch for the current task, create a work-in-progress branch.
- Ask before initializing a new git repository if the project is not already in one.
- Ask how to handle uncommitted changes or untracked files when starting work. Suggest committing existing work first.

### Hooks

{{#PRE_COMMIT_ENABLED}}
- NEVER skip, evade, or disable a pre-commit hook.
- Ensure all pre-commit hooks pass before committing.
{{/PRE_COMMIT_ENABLED}}
