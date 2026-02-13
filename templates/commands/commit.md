# Smart Commit

Create a well-formatted git commit with a conventional commit message. Run automatically — no confirmation needed unless a serious error occurs.

## Workflow

1. **If `$ARGUMENTS` provided** — use it as the commit message description, skip to step 4.

2. **Pre-commit validation** — run lint and build checks:
   - JS: run lint (`biome check .` / `eslint .`) and build
   - Python: run `ruff check .` and type check
   - If either fails, ask the user: fix first or proceed anyway?

3. **Stage changes**:
   - Run `git status --porcelain` to check state
   - If nothing staged: run `git add .` to stage all modified files
   - If files already staged: commit only those

4. **Analyze the diff**:
   - Run `git diff --cached` to inspect what will be committed
   - Determine primary change type (feat, fix, docs, refactor, etc.)
   - Identify scope and purpose

5. **Generate commit message**:
   - Format: `<type>(<scope>): <description>`
   - Keep description concise, imperative mood, under 72 chars
   - Show proposed message to user before committing

6. **Commit and push**:
   - Run `git commit -m "<message>"`
   - Run `git push`
   - Show commit hash and brief summary

## Commit Types

| Type | When to use |
|------|------------|
| feat | New feature or capability |
| fix | Bug fix |
| docs | Documentation only |
| style | Formatting, whitespace — no logic change |
| refactor | Restructure without adding feature or fixing bug |
| perf | Performance improvement |
| test | Add or fix tests |
| chore | Tooling, config, dependencies, build process |
| ci | CI/CD pipeline changes |
| revert | Revert a previous commit |

## Good Examples

```
feat(auth): add JWT-based user authentication
fix(cart): resolve null pointer in total calculation
docs(api): document rate limiting behaviour
refactor(payment): extract payment logic into service layer
fix(auth): sanitize user input to prevent XSS
test(discount): add edge case coverage for discount engine
chore(deps): update biome to v2 and fix new lint warnings
fix(auth): patch critical auth bypass on admin routes
perf(db): add index on users.email to speed up lookups
revert: revert feat(auth) — causes session conflicts
```
