## Code Organization

### Directory Structure

- Place source code in `src/`.
- Place tests in `tests/` (with subdirectories for `unit/`, `integration/`, `e2e/` as needed).
- Place shared code in `src/shared/` or `packages/shared/` only if used by two or more packages. Do not prematurely extract.

### Module Extraction

- Do NOT extract a new module or function unless:
  - It is used in more than one place, OR
  - It is needed to unit-test otherwise untestable logic, OR
  - The original is extremely hard to follow and extraction is the only way to improve readability.

### Structured Data

- Use typed data structures (TypedDict, dataclass, interfaces, type aliases) for structured data.
- Use branded/newtype patterns for domain identifiers rather than bare primitives.

### Security & Safety Patterns

**Never expose sensitive information:**
- Do not log passwords, tokens, or API keys.
- Do not expose internal error details in user-facing responses.
- Validate and sanitize all user input at system boundaries.
- Use parameterized queries — never string-interpolate SQL.

**Always use environment variables for secrets:**
- Never hardcode credentials, API keys, or connection strings.
- Validate required env vars on startup; fail fast with a clear error if missing.
- Use different configs for dev/staging/production.

**File system safety:**
- Validate file paths before use — prevent path traversal (`../../etc/passwd`).
- Use absolute paths when possible.
- Handle file-not-found and permission errors explicitly.
- Close file handles and release resources properly.

### Dependency Management

- Pin dependency versions for reproducibility.
- Regularly audit dependencies for known CVEs (`bun audit` / `pip-audit` / `cargo audit`).
- Minimise the number of dependencies — prefer stdlib when practical.
- Document why each non-obvious dependency is needed.
- Remove unused dependencies promptly.

### Pre-commit Checklist

Before committing, verify:
- [ ] No hardcoded secrets or credentials
- [ ] All user input validated at entry points
- [ ] Error handling present and specific (not bare `except` / `catch`)
- [ ] No sensitive data in logs or error messages
- [ ] Tests written and passing
- [ ] No unused imports or dead code committed
