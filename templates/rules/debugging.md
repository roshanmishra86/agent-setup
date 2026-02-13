## Debugging

Always find the root cause of any issue. Never fix a symptom or add a workaround instead of finding the root cause.

Follow this systematic debugging framework for any technical issue:

### Phase 1: Root Cause Investigation (BEFORE attempting fixes)

- **Read error messages carefully.** Do not skip past errors or warnings — they often contain the exact solution.
- **Reproduce consistently.** Ensure the issue can be reliably reproduced before investigating.
- **Check recent changes.** What changed that could have caused this? Review diffs, recent commits, and configuration changes.

### Phase 2: Pattern Analysis

- **Find working examples.** Locate similar working code in the same codebase.
- **Compare against references.** If implementing a pattern, read the reference implementation completely.
- **Identify differences.** What is different between working and broken code?
- **Understand dependencies.** What other components or settings does this pattern require?

### Phase 3: Hypothesis and Testing

1. **Form a single hypothesis.** State what the root cause is, clearly.
2. **Test minimally.** Make the smallest possible change to test the hypothesis.
3. **Verify before continuing.** Did the test work? If not, form a new hypothesis — do not add more fixes.
4. **When uncertain, say so.** State "I don't understand X" rather than guessing.

### Phase 4: Implementation Rules

- Always have the simplest possible failing test case.
- Never add multiple fixes at once.
- Never claim to implement a pattern without reading it completely first.
- Always test after each change.
- If the first fix does not work, stop and re-analyze rather than adding more fixes.

### Reporting Issues

When a failure is found, always follow **Report → Propose → Approve → Fix**:

1. **Report** the failure clearly: what broke, where, and what the error says.
2. **Propose** a specific fix with reasoning.
3. **Wait for approval** before applying the fix.
4. **Fix** and re-validate.

NEVER auto-fix silently. NEVER apply multiple speculative fixes hoping one will work.

### Issue Severity Format

When reporting problems (in reviews, analysis, or debugging sessions), use consistent severity levels:

- **[CRITICAL]** — Must fix before proceeding. Causes data loss, security vulnerability, crashes, or incorrect results.
- **[WARNING]** — Should fix soon. Degrades quality, reliability, or maintainability.
- **[SUGGESTION]** — Nice to have. Minor improvement, style, or optional refactor.

**Report format:**
```
[CRITICAL] src/auth.ts:42
  Issue: Password stored in plain text
  Fix: Hash with bcrypt before storing

[WARNING] src/user.ts:15
  Issue: No input validation on email field
  Fix: Validate format before processing

[SUGGESTION] src/utils.ts:28
  Issue: Loop could be replaced with array method
  Fix: Use .filter().map() for clarity
```
