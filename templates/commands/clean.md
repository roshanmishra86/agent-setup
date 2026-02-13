# Code Cleanup

Clean and prepare code for production. Apply the full quality pipeline to the specified files or recently modified files.

**Usage:** `/clean [file-or-directory]`

If no argument provided, check `git status` for modified files.

## Cleanup Pipeline

Run in this order:

**1. Remove debug artifacts**
- Strip `console.log`, `print()`, `debugger` statements and temporary debug code
- Remove commented-out code blocks
- Clean up development-only imports (e.g., mock data, debug helpers)

**2. Format code**
- Run formatter if available (Prettier, Biome, Black, Ruff)
- Enforce consistent indentation, spacing, and quote style

**3. Optimize imports**
- Sort imports (stdlib → third-party → local)
- Remove unused imports
- Group and organize import blocks

**4. Fix linting issues**
- Run linter (`biome check`, `eslint`, `ruff check`, etc.)
- Apply all auto-fixable rules
- Report any issues that require manual fixing

**5. Type safety**
- Run type checker if applicable (`tsc --noEmit`, `mypy`, `pyright`)
- Fix obvious type errors
- Add missing annotations where they add clarity

**6. Comment quality**
- Remove redundant or obvious comments (e.g., `// increment i`)
- Improve vague comments
- Ensure public APIs have clear docstrings

## Report

After cleanup, present:

---

## Cleanup Report

### Files Processed
[list of cleaned files]

### Actions Taken
- **Debug code removed:** [count of console.logs, debuggers, etc.]
- **Formatting applied:** [files formatted]
- **Imports optimized:** [unused removed, sorted]
- **Lint issues fixed:** [count of auto-fixed issues]
- **Type issues resolved:** [count]
- **Comments improved:** [redundant removed, unclear improved]

### Manual Actions Needed
[Issues that require human review — list specifically with file:line]

### Result
[Summary of overall quality improvement]

---

## Principles
- Only remove code that is definitively unused/debug — never speculate
- Do not refactor logic, only clean up form and artifacts
- Report but do not auto-fix issues that could change behaviour
