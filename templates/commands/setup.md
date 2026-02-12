# Project Setup

Verify the development environment is correctly configured before starting work.

## Checklist

1. Confirm the project has an `AGENTS.md` file with development guidelines.
2. Verify the language toolchain is installed and working:
   - **Python:** `uv` is available, `uv sync` succeeds.
   - **JavaScript:** `bun` is available, `bun install` succeeds.
3. Verify tests pass: run the test suite and confirm all tests are green.
4. Verify linting passes: run the linter and confirm no errors.
5. If a task list exists (`tasks/`), review it and check off any completed work.

## Python Projects

- Package manager: `uv`
- Run scripts: `uv run <script.py>`
- Add packages: `uv add <package>`
- Dependencies defined in `pyproject.toml`

## JavaScript Projects

- Package manager: `bun`
- Run scripts: `bun run <script>`
- Add packages: `bun add <package>`
- Dependencies defined in `package.json`
