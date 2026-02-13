# setup-config

Scaffolding tool that generates a new project pre-wired with AI agent configurations, CI, and pre-commit hooks — in a single command.

Instead of manually creating and maintaining separate config files for each AI tool you use, this generates all of them from one shared source of truth: `AGENTS.md`. Every agent-specific file (CLAUDE.md, .cursor/rules/, copilot-instructions.md, .windsurfrules, etc.) is derived from it, so your guidelines stay consistent across tools.

## What you get

Running `./build.sh js -n my-app` creates a ready-to-work project:

```
my-app/
├── AGENTS.md                        # Universal guidelines — all agents read this
├── CLAUDE.md                        # Claude Code / Claude CLI
├── GEMINI.md                        # Gemini CLI
├── CONVENTIONS.md                   # Aider conventions
├── .windsurfrules                   # Windsurf
├── .aider.conf.yml                  # Aider config
├── .cursor/rules/*.mdc              # Cursor rules
├── .github/
│   ├── copilot-instructions.md      # GitHub Copilot
│   └── workflows/ci.yml             # GitHub Actions CI
├── .clinerules/*.md                 # Cline
├── .amazonq/rules/*.md              # Amazon Q
├── .agents/commands/*.md            # Workflow slash commands
├── .claude/commands/                # Claude Code skills (optional)
├── .pre-commit-config.yaml
├── .gitignore
├── README.md
├── src/
├── tests/
└── package.json / pyproject.toml
```

The `.agents/commands/` folder contains workflow commands that work with any AI tool supporting slash commands or custom prompts — things like `/commit`, `/test`, `/clean`, `/optimize`, and `/worktrees`.

## Quick start

```bash
# JavaScript/TypeScript project
./build.sh js -n my-app

# Python project
./build.sh py -n my-api

# With a custom config
cp config.default.yml config.yml
# edit config.yml to your preferences
./build.sh js -n my-app -c config.yml

# Only generate configs for specific tools
./build.sh js -n my-app --agents claude,cursor,copilot
```

Then `cd my-app` and start working.

## Prerequisites

- **git**
- **bun** — for JavaScript projects ([install](https://bun.sh/))
- **uv** — for Python projects ([install](https://docs.astral.sh/uv/))

## CLI reference

```
Usage: build.sh <js|py> -n <name> [options]

Arguments:
  js                    JavaScript/TypeScript project
  py                    Python project

Options:
  -n, --name NAME       Project name (required)
  -c, --config FILE     Config file to use (overrides config.default.yml)
  --no-ci               Skip CI workflow generation
  --no-hooks            Skip pre-commit hook generation
  --agents LIST         Comma-separated agents to generate
                        Available: agents_md, claude, cursor, copilot,
                                   windsurf, cline, aider, amazonq, gemini
  -h, --help            Show help
```

## Configuration

Copy `config.default.yml` to `config.yml` and change what you want:

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
    - windsurf
```

The full list of options with their defaults is in `config.default.yml`.

## Supported agents

| Agent | Config generated |
|-------|-----------------|
| Claude Code | `CLAUDE.md` |
| Gemini CLI | `GEMINI.md` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Cursor | `.cursor/rules/*.mdc` |
| Windsurf | `.windsurfrules` |
| Cline | `.clinerules/*.md` |
| Aider | `.aider.conf.yml` + `CONVENTIONS.md` |
| Amazon Q | `.amazonq/rules/*.md` |

## Workflow commands

The generated project includes a set of workflow commands in `.agents/commands/`. These are markdown files structured as prompts — paste them into your AI tool's chat, use them as slash commands, or reference them however your tool supports custom instructions.

| Command | What it does |
|---------|-------------|
| `commit.md` | Staged diff → conventional commit message |
| `test.md` | Type check → lint → tests, stop on first failure |
| `clean.md` | Strip debug code, format, sort imports, fix lint |
| `optimize.md` | Performance, security, and edge-case analysis |
| `worktrees.md` | Git worktree management for parallel branches |
| `generate-tasks.md` | Break a feature into a phased task list |
| `process-task-list.md` | Execute a task list step by step |
| `create-prd.md` | Turn a feature idea into a structured PRD |

## Templates

The `templates/` directory is where all the content comes from. You can edit anything here before running the build.

```
templates/
├── rules/              # Guidelines assembled into AGENTS.md
│   ├── coding-style.md
│   ├── testing.md
│   ├── debugging.md
│   ├── code-organization.md
│   ├── code-review.md
│   ├── task-management.md
│   ├── version-control.md
│   ├── tooling-js.md
│   └── tooling-py.md
├── commands/           # Workflow commands copied to .agents/commands/
└── skills/             # Claude Code skills (optional, copied to .claude/commands/)
```

To add your own rules: create a `.md` file in `templates/rules/` and add it to the assembly in `lib/generate_agents.sh`.

## License

MIT
