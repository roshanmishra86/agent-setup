## Code Review

When reviewing code — whether a PR, a diff, or a specific file — follow this structured process.

### Principles

- **Constructive:** Focus on the code, not the person. Explain *why* something is an issue and suggest a specific improvement.
- **Thorough:** Check functionality, not just style. Consider edge cases, security, and maintainability.
- **Prioritized:** Use severity levels so the author knows what must be fixed vs what is optional.

### Review Checklist

**Functionality**
- [ ] Does what it's supposed to do
- [ ] Edge cases handled (empty input, null values, boundaries)
- [ ] Error cases handled with appropriate responses
- [ ] No obvious bugs or off-by-one errors

**Code Quality**
- [ ] Clear, descriptive naming (functions, variables, types)
- [ ] Functions small and focused (ideally < 50 lines)
- [ ] No unnecessary complexity or deep nesting
- [ ] Follows project coding standards
- [ ] DRY — no duplicated logic

**Security**
- [ ] User input validated and sanitized
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities
- [ ] No hardcoded secrets or credentials
- [ ] Sensitive data handled appropriately (not logged, not exposed in errors)
- [ ] Auth/authorization checks in place where needed

**Testing**
- [ ] Tests present for new/changed behaviour
- [ ] Happy path covered
- [ ] Edge cases covered
- [ ] Error cases covered
- [ ] All tests pass

**Performance**
- [ ] No obviously inefficient algorithms (unnecessary O(n²), nested loops on large data)
- [ ] No N+1 query patterns
- [ ] Resources properly managed (connections closed, handles released)

**Maintainability**
- [ ] Logic is understandable without extensive comments
- [ ] Complex sections have explanatory comments (explaining *why*, not *what*)
- [ ] Follows project conventions consistently
- [ ] Easy to modify or extend without major restructuring

### Severity Levels

Use these consistently when reporting findings:

- **[CRITICAL]** — Must fix before merge. Security vulnerability, data loss risk, crash, or functionally incorrect.
- **[WARNING]** — Should fix. Degrades reliability, performance, or maintainability.
- **[SUGGESTION]** — Optional improvement. Style, readability, or minor refactor.

### Review Report Format

```
## Code Review: {Feature / PR / File}

**Summary:** {1-2 sentences describing what was reviewed and overall assessment}
**Assessment:** Approve / Needs Work / Requires Changes

---

### Issues

[CRITICAL] src/auth.ts:42
  Issue: Password stored in plain text
  Fix: Hash with bcrypt before storing

[WARNING] src/api/users.ts:15
  Issue: No input validation on email parameter
  Fix: Validate format and sanitize before DB query

[SUGGESTION] src/utils/format.ts:28
  Issue: Loop could use .map()
  Fix: const results = items.map(transform)

---

### Positive Observations
- {Something done well — acknowledge good work}
- {Another positive}

---

### Recommendations
{Next steps, follow-up items, or patterns to adopt going forward}
```

### Common Issues Reference

**Security — [CRITICAL]**
- Hardcoded credentials or API keys
- SQL injection (string-interpolated queries)
- Missing input validation
- Exposed sensitive data in responses or logs

**Code Quality — [WARNING]**
- Functions > 50 lines
- Nesting > 3 levels deep
- Duplicated logic that should be extracted
- Unclear or misleading names

**Testing — [WARNING]**
- Missing tests for new behaviour
- Coverage below threshold
- Tests that only test mocks, not real logic
