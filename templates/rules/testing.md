## Testing

### Philosophy

{{#TDD_STRICT}}
- Follow strict TDD for every new feature and bugfix:
  1. Write a failing test that correctly validates the desired functionality.
  2. Run the test to confirm it fails as expected.
  3. Write ONLY enough code to make the failing test pass.
  4. Run the test to confirm success.
  5. Refactor if needed while keeping tests green.
{{/TDD_STRICT}}
{{#TDD_RELAXED}}
- Follow TDD when practical. Write tests before or alongside implementation.
- For exploratory work, tests may follow implementation but must be written before the task is considered complete.
{{/TDD_RELAXED}}
{{#TEST_AFTER}}
- Write comprehensive tests after implementation, before marking work as complete.
- Every feature and bugfix must have corresponding tests before it is merged.
{{/TEST_AFTER}}

### Requirements

- Tests MUST comprehensively cover all functionality.
- All projects MUST have unit tests{{#REQUIRE_INTEGRATION}} and integration tests{{/REQUIRE_INTEGRATION}}{{#REQUIRE_E2E}} and end-to-end tests{{/REQUIRE_E2E}}.
- Target a minimum of {{COVERAGE_THRESHOLD}}% code coverage.
- Separate pure-logic unit tests from tests that touch external systems (DB, APIs).
- Prefer integration tests over heavy mocking for core flows.

### Rules

- NEVER write tests that only test mocked behavior instead of real logic.
- NEVER mock the functionality being tested.
- NEVER mock in end-to-end tests. Use real data and real APIs.
- NEVER ignore test output — logs and messages often contain critical information.
- Test output must be clean to pass. If logs are expected to contain errors, capture and assert on them.

### Best Practices

- Parameterize test inputs; never embed unexplained literals directly in tests.
- Do not add a test unless it can fail for a real defect.
- Test names should state exactly what the assertion verifies.
- Compare results to independent, pre-computed expectations, never to the function's own output reused as the oracle.
- Test edge cases, realistic input, unexpected input, and boundaries.
- Use strong assertions (`assert x == 1`) over weak ones (`assert x >= 1`).
- Group related tests together.
{{#TOOLING_JS}}

### Test Commands

```bash
bun test                    # Run all tests
bun test --coverage         # Run with coverage
```
{{/TOOLING_JS}}
{{#TOOLING_PY}}

### Test Commands

```bash
{{PY_RUNNER}} pytest -q                     # Run all tests
{{PY_RUNNER}} pytest --cov=src              # Run with coverage
{{PY_RUNNER}} pytest tests/integration/     # Run integration tests only
```
{{/TOOLING_PY}}
