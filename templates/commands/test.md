# Testing Pipeline

Run the complete quality gate: type checking, linting, and tests. Fix failures before proceeding.

**Usage:** `/test [file-or-pattern]`

If `$ARGUMENTS` provided, run tests scoped to those files/patterns. Otherwise run the full suite.

## Pipeline

Run in this order, stop and report on first failure:

**1. Type check**
- JS/TS: `tsc --noEmit` (or `bunx tsc --noEmit`)
- Python: `mypy .` / `pyright .`
- Fix any type errors before continuing

**2. Lint**
- JS/TS: `biome check .` / `eslint .`
- Python: `ruff check .`
- Fix auto-fixable issues; report manual ones

**3. Tests**
- JS/TS: `bun test` / `vitest run` / `jest`
- Python: `pytest` / `uv run pytest`
- Scope to `$ARGUMENTS` if provided

**4. Report results**

```
## Test Results

### Type Check   [pass / fail]
[output or errors]

### Lint         [pass / fail]
[issues found or "clean"]

### Tests        [pass / fail]
Passed: X  Failed: Y  Skipped: Z
[failing test names and errors]
```

**5. Fix failures**
- Diagnose root cause of each failure
- Fix one at a time, re-run after each fix
- Do NOT apply multiple speculative fixes at once
- If a fix doesn't work: stop, report, ask for direction

**6. Repeat until green**

All three checks must pass before declaring success.

## Rules
- NEVER mark tests as passing when they are not
- NEVER skip or suppress failing tests without explicit user approval
- STOP and report if a fix attempt doesn't resolve the failure — do not keep guessing
