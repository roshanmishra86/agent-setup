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
