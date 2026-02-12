## Tooling (Python)

### Package Management

- Use **uv** for package management.
- Do not use `requirements.txt` — dependencies are defined in `pyproject.toml`.
- Run scripts: `uv run <script.py>`
- Add packages: `uv add <package>`
- Add dev packages: `uv add --dev <package>`
- Sync environment: `uv sync`

### Linting and Formatting

{{#LINT_RUFF}}
- Use **Ruff** for linting and formatting.
- Commands:
  ```bash
  uv run ruff check .           # Lint
  uv run ruff check --fix .     # Lint and auto-fix
  uv run ruff format .          # Format
  ```
{{/LINT_RUFF}}
{{#LINT_FLAKE8}}
- Use **Flake8** for linting.
- Commands:
  ```bash
  uv run flake8 .               # Lint
  ```
{{/LINT_FLAKE8}}
{{#FORMAT_BLACK}}
- Use **Black** for formatting.
- Commands:
  ```bash
  uv run black .                # Format
  uv run black --check .        # Check formatting
  ```
{{/FORMAT_BLACK}}

### Type Checking

{{#TYPE_MYPY}}
- Use **mypy** for type checking.
- Commands:
  ```bash
  uv run mypy .                 # Type check
  ```
{{/TYPE_MYPY}}
{{#TYPE_PYRIGHT}}
- Use **Pyright** for type checking.
- Commands:
  ```bash
  uv run pyright .              # Type check
  ```
{{/TYPE_PYRIGHT}}

### Testing

- Use **pytest** for unit and integration tests.
- Use **hypothesis** for property-based testing where appropriate.
- Commands:
  ```bash
  uv run pytest -q              # Run all tests
  uv run pytest --cov=src       # Run with coverage
  ```

### CI Gate Commands

```bash
{{PY_LINT_CMD}}
{{PY_FORMAT_CMD}}
{{PY_TYPE_CMD}}
uv run pytest -q
```
