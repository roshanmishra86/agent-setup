# Code Optimization Analysis

Analyze code for performance issues, security vulnerabilities, and hidden problems. Provide a structured, prioritized report.

**Usage:** `/optimize [file-or-directory]`

If no argument provided, analyze recently modified files via `git status` and `git diff --name-only HEAD~5`.

## Analysis Steps

### 1. Determine scope
- If `$ARGUMENTS`: analyze those files/directories
- Otherwise: check `git status` for modified files and recently changed files

### 2. Performance review

- **Algorithmic efficiency** — O(n²) or worse, unnecessary nested loops, redundant calculations
- **Memory** — leaks, excessive allocations, large objects held longer than needed
- **I/O** — unnecessary API calls, missing caching, blocking ops that could be async
- **Framework-specific** — React: missing memoization; DB: N+1 queries, missing indexes; Frontend: bundle size

### 3. Security scan

- **Input validation** — missing sanitization, SQL injection, XSS, path traversal
- **Auth/authz** — missing checks, weak session management, privilege escalation risks
- **Data protection** — sensitive data in logs/errors, missing rate limiting, insecure endpoints
- **Dependencies** — outdated packages with known CVEs, unnecessary packages expanding attack surface

### 4. Hidden problem detection

- **Error handling** — missing try/catch, silent failures, poor error feedback
- **Edge cases** — null/undefined handling, empty collections, network failure scenarios, race conditions
- **Scalability** — hard-coded limits, single points of failure, resource exhaustion risks
- **Maintainability** — duplication, overly complex functions, tight coupling

### 5. Report

Present findings using this format:

---

## Optimization Analysis

### Scope
- **Files:** [list]
- **Languages/Frameworks:** [detected]

### Performance
#### [CRITICAL]
- **Issue:** [problem] | **Location:** `file:line` | **Fix:** [approach]

#### Improvements
- **Optimization:** [opportunity] | **Gain:** [expected benefit]

### Security
#### [CRITICAL]
- **Vulnerability:** [flaw] | **Risk:** High/Medium/Low | **Fix:** [steps]

#### Hardening opportunities
- [enhancement and benefit]

### Edge Cases & Hidden Issues
- **Issue:** [problem] | **Scenario:** [when it triggers] | **Fix:** [solution]

### Maintainability
- **Problem:** [concern] | **Location:** `file:line` | **Refactor:** [approach]

### Recommendations by priority

**Priority 1 — Critical**
1. [Most impactful fix]

**Priority 2 — Important**
1. [Significant improvement]

**Priority 3 — Nice to have**
1. [Code quality improvement]

### Expected impact
- **Performance:** [gains]
- **Security:** [risk reduction]
- **Maintainability:** [improvements]

---

## Principles
- Fix actual bottlenecks, not premature optimizations
- Security issues always Priority 1
- Ensure fixes don't sacrifice code clarity
- Focus on measurable, tangible improvements
