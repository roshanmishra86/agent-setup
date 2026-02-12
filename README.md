# setup-config

Universal AI agent project scaffolding tool. Generates projects with configs for **all major AI coding agents** — Claude, Cursor, Copilot, Windsurf, Cline, Aider, Amazon Q, and Gemini — plus CI/CD and pre-commit hooks.

## How It Works

1. **AGENTS.md** is the single source of truth for development guidelines.
2. Agent-specific configs (CLAUDE.md, .cursor/rules/, .github/copilot-instructions.md, etc.) are **derived** from AGENTS.md.
3. All rules are modular, configurable, and agent-agnostic.

## Quick Start

```bash
# JavaScript project
./build.sh js -n my-app

# Python project
./build.sh py -n my-api

# With custom config
cp config.default.yml config.yml
# edit config.yml...
./build.sh js -n my-app -c config.yml

# Selective agents, no CI
./build.sh js -n my-app --no-ci --agents claude,cursor,copilot
```

## CLI Reference

```
Usage: build.sh <js|py> -n <name> [options]

Arguments:
  js                    JavaScript/TypeScript project (requires bun)
  py                    Python project (requires uv)

Options:
  -n, --name NAME       Project name (required)
  -c, --config FILE     Path to config.yml overrides
  --no-ci               Skip CI workflow generation
  --no-hooks            Skip pre-commit hook generation
  --agents LIST         Comma-separated agents to generate
  -h, --help            Show help
```

## Configuration

Copy `config.default.yml` to `config.yml` and override what you need:

```yaml
coding:
  style: "functional"          # functional | classes | mixed
  comments: "minimal"          # minimal | moderate

testing:
  philosophy: "tdd-strict"     # tdd-strict | tdd-relaxed | test-after
  coverage_threshold: 80

agents:
  generate:
    - claude
    - cursor
    - copilot
```

See `config.default.yml` for the full schema.

## Generated Output

Running `./build.sh js -n my-app` produces:

```
my-app/
├── AGENTS.md                   # Universal guidelines (all agents read this)
├── CLAUDE.md                   # Claude Code
├── GEMINI.md                   # Gemini CLI
├── CONVENTIONS.md              # Aider conventions
├── .windsurfrules              # Windsurf
├── .aider.conf.yml             # Aider config
├── .cursor/rules/*.mdc         # Cursor rules
├── .github/
│   ├── copilot-instructions.md # GitHub Copilot
│   └── workflows/ci.yml        # GitHub Actions CI
├── .clinerules/*.md            # Cline rules
├── .amazonq/rules/*.md         # Amazon Q rules
├── .agents/commands/*.md       # Workflow commands
├── .pre-commit-config.yaml
├── .gitignore
├── README.md
├── src/
├── tests/
└── package.json / pyproject.toml
```

## Supported Agents

| Agent | Config File(s) |
|-------|----------------|
| Claude Code | `CLAUDE.md` |
| Gemini CLI | `GEMINI.md` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Cursor | `.cursor/rules/*.mdc` |
| Windsurf | `.windsurfrules` |
| Cline | `.clinerules/*.md` |
| Aider | `.aider.conf.yml` + `CONVENTIONS.md` |
| Amazon Q | `.amazonq/rules/*.md` |

## Prerequisites

- **git**
- **bun** (for JS projects) — [install](https://bun.sh/)
- **uv** (for PY projects) — [install](https://docs.astral.sh/uv/)

## License

MIT
