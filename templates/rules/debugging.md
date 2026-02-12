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
