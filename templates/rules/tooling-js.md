## Tooling (JavaScript / TypeScript)

### Package Management

- Use **Bun** for package management and script running.
- Do not use `package-lock.json` — Bun uses `bun.lock` automatically.
- Run scripts: `bun run <script>`
- Add packages: `bun add <package>`
- Add dev packages: `bun add -d <package>`
- Packages are defined in `package.json`.

### Linting and Formatting

{{#LINT_BIOME}}
- Use **Biome** for linting and formatting.
- Commands:
  ```bash
  bunx biome check .            # Lint
  bunx biome check --write .    # Lint and auto-fix
  bunx biome format --write .   # Format
  ```
{{/LINT_BIOME}}
{{#LINT_ESLINT}}
- Use **ESLint** for linting.
- Commands:
  ```bash
  bunx eslint .                 # Lint
  bunx eslint --fix .           # Lint and auto-fix
  ```
{{/LINT_ESLINT}}
{{#FORMAT_PRETTIER}}
- Use **Prettier** for formatting.
- Commands:
  ```bash
  bunx prettier --check .       # Check formatting
  bunx prettier --write .       # Format
  ```
{{/FORMAT_PRETTIER}}

### Testing

- Use Bun's built-in test runner.
- Commands:
  ```bash
  bun test                      # Run all tests
  bun test --coverage           # Run with coverage
  ```

### CI Gate Commands

```bash
{{JS_LINT_CMD}}
bun test
```
