## Code Style and Design

### Design Principles

- **YAGNI.** The best code is no code. Do not add features that are not needed right now.
- Design for extensibility and flexibility.
- Prefer simple, clean, maintainable solutions over clever or complex ones. Readability and maintainability are primary concerns, even at the cost of conciseness or performance.
- Make the smallest reasonable changes to achieve the desired outcome.
- Never make code changes unrelated to the current task. Document unrelated issues separately rather than fixing them immediately.
- Work hard to reduce code duplication, even if refactoring takes extra effort.
- Match the style and formatting of surrounding code. Consistency within a file trumps external standards.

### Coding Style

{{#STYLE_FUNCTIONAL}}
- Prefer {{CODING_STYLE}} style: use small, composable, testable functions.
- Do not introduce classes when small, testable functions suffice.
{{/STYLE_FUNCTIONAL}}
{{#STYLE_CLASSES}}
- Use classes to organize related behavior and state.
- Keep class interfaces small and focused.
{{/STYLE_CLASSES}}
{{#STYLE_MIXED}}
- Use whichever approach (functions or classes) best fits the problem at hand.
- Prefer functions for stateless operations and classes for stateful entities.
{{/STYLE_MIXED}}

### Naming

- Names MUST tell what code does, not how it is implemented or its history.
- NEVER use implementation details in names (e.g., "ZodValidator", "MCPWrapper", "JSONParser").
- NEVER use temporal/historical context in names (e.g., "NewAPI", "LegacyHandler", "UnifiedTool").
- NEVER use pattern names unless they add clarity (e.g., prefer `Tool` over `ToolFactory`).
- Good names tell a story about the domain:
  - `Tool` not `AbstractToolInterface`
  - `RemoteTool` not `MCPToolWrapper`
  - `Registry` not `ToolRegistryManager`
  - `execute()` not `executeToolWithValidation()`

### Comments

{{#COMMENTS_MINIMAL}}
- Keep comments minimal. Rely on self-explanatory code and docstrings for public APIs.
- Only add comments for critical caveats that cannot be expressed through naming or structure.
{{/COMMENTS_MINIMAL}}
{{#COMMENTS_MODERATE}}
- Add comments for non-obvious logic, critical caveats, and public API documentation.
- Do not comment obvious code, but do explain the "why" behind complex decisions.
{{/COMMENTS_MODERATE}}
- Comments must describe what the code does NOW, not what it used to do, how it was refactored, or what framework it uses internally.
- Never remove existing code comments unless they are provably false.
- Never add comments about what used to be there or how something has changed.

### Functions

- Keep functions under {{MAX_FUNCTION_LINES}} lines where practical.
- Do NOT extract a new function unless it will be reused, is needed to unit-test otherwise untestable logic, or drastically improves readability.
- Name functions and classes using existing domain vocabulary for consistency.
- Use branded/newtype patterns for IDs rather than plain strings or integers.
