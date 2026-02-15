# setup-config

Scaffolding tool that generates a new project pre-wired with AI agent configurations, CI, and pre-commit hooks — in a single command.

Instead of manually creating and maintaining separate config files for each AI tool you use, this generates all of them from one shared source of truth: `AGENTS.md`. Every agent-specific file (CLAUDE.md, .cursor/rules/, GEMINI.md, etc.) is derived from it, so your guidelines stay consistent across tools. Some tools (Copilot, Codex, OpenCode) read `AGENTS.md` directly and need no extra config.

## What you get

Running `./build.sh js -n my-app` creates a ready-to-work project:

```
my-app/
├── AGENTS.md                        # Universal guidelines (OpenCode, Codex read this directly)
├── CLAUDE.md                        # Claude Code
├── GEMINI.md                        # Gemini CLI
├── opencode.json                    # OpenCode MCP config (if MCPs configured)
├── .agent/rules/*.md                # Antigravity rules (activation frontmatter)
├── .cursor/
│   ├── rules/*.mdc                  # Cursor rules
│   └── mcp.json                     # Cursor MCP servers (if MCPs configured)
├── .gemini/
│   └── settings.json                # Gemini CLI MCP servers (if MCPs configured)
├── .mcp.json                        # Claude Code MCP servers (if MCPs configured)
├── .github/
│   └── workflows/ci.yml             # GitHub Actions CI
├── .agents/commands/*.md            # Workflow slash commands
├── .claude/commands/                # Claude Code skills
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
- **jq** — for MCP config generation ([install](https://jqlang.github.io/jq/download/))
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
  -o, --output-dir DIR  Parent directory for the project (default: current dir)
  --no-ci               Skip CI workflow generation
  --no-hooks            Skip pre-commit hook generation
  --dry-run             Show what files would be generated without creating them
  --agents LIST         Comma-separated agents to generate
                        Available: agents_md, opencode, claude, codex, copilot,
                                   antigravity, cursor, gemini
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
```

The full list of options with their defaults is in `config.default.yml`.

## Supported agents

| Agent | Config generated | Notes |
|-------|-----------------|-------|
| OpenCode | `opencode.json` (MCP only) | Reads `AGENTS.md` natively |
| Claude Code | `CLAUDE.md`, `.mcp.json` | |
| Codex CLI | — | Reads `AGENTS.md` natively |
| Copilot | — | Reads `AGENTS.md` natively |
| Antigravity | `.agent/rules/*.md` | Rules with `activation: always_on` frontmatter |
| Cursor | `.cursor/rules/*.mdc`, `.cursor/mcp.json` | Rules with YAML frontmatter |
| Gemini CLI | `GEMINI.md`, `.gemini/settings.json` | |

OpenCode is the default — it's the first entry in `config.default.yml` and the recommended starting point.

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

## MCP servers

MCP (Model Context Protocol) servers extend your AI tool with extra capabilities. This tool can configure project-level MCP servers that are available whenever you open the project — no global installation needed.

## CLI enhancements
 
The tool generates configuration to supercharge your terminal workflow:
 
- **Justfile**: A modern command runner (like Make, but better). Run `just setup`, `just dev`, `just test` without remembering tool-specific commands.
- **Direnv**: An `.envrc` file that automatically activates your Python virtual environment or sets up Node paths when you `cd` into the directory.
- **Tmux Integration**: A `start-dev.sh` script that launches a tmux session with pre-configured windows for editor, server, and tests.
- **EditorConfig**: Standardizes indentation and encoding across editors (`.editorconfig`).
- **Setup Script**: A helper script (`scripts/setup-dev-tools.sh`) to install these CLI tools (plus `bun`) on Linux and macOS.
 
Enable these in `config.yml`:
 
```yaml
cli:
  tools:
    justfile: true
    direnv: true
    tmux: true
    editorconfig: true
    setup_script: true
```
 
```yaml
mcps:
  context7: true           # Up-to-date library docs
  playwright: true         # Browser automation
  sequential-thinking: true
  tavily: true             # Requires TAVILY_API_KEY env var
```

When any server is enabled, a config file is generated for each enabled agent that supports project-level MCP:

| Tool | File | Format |
|------|------|--------|
| Claude Code | `.mcp.json` | Standard `mcpServers` |
| Cursor | `.cursor/mcp.json` | Standard `mcpServers` |
| Gemini CLI | `.gemini/settings.json` | Standard `mcpServers` |
| OpenCode | `opencode.json` | OpenCode `mcp.type/command` |

Codex and Antigravity configure MCP globally only — no project-level file is generated for them.

### Available servers

| Server | Package | What it adds | API key? |
|--------|---------|-------------|----------|
| `context7` | `@upstash/context7-mcp` | Pulls live, version-accurate docs for any library directly into your prompt | No |
| `playwright` | `@playwright/mcp@latest` | Browser automation — navigate, click, fill forms, take screenshots, scrape | No |
| `sequential-thinking` | `@modelcontextprotocol/server-sequential-thinking` | Structured multi-step reasoning for complex problems | No |
| `tavily` | `tavily-mcp@latest` | Real-time web search and content extraction | Yes — `TAVILY_API_KEY` |

All servers run via `npx` so there's nothing to install globally. Node.js must be available.

### Adding your own

To add an MCP server not listed above, edit `lib/generate_mcp.sh` and add a new `cfg_is` / `jq` block in the `generate_mcp` function, following the same pattern as the existing entries.

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

## Development

### Running tests

The project uses [BATS](https://github.com/bats-core/bats-core) (Bash Automated Testing System) for unit and integration tests.

```bash
# Install BATS
bun install -g bats

# Run all tests
bash tests/run.sh
```

Tests cover:

- **Config parsing** (`tests/parse_config.bats`) — YAML parsing, merging, accessors
- **Template engine** (`tests/utils.bats`) — conditionals, variable substitution, rendering
- **CLI arguments** (`tests/cli_args.bats`) — validation, help text, edge cases

### Shellcheck

```bash
# Lint all shell scripts
bash tests/shellcheck.sh
```

## License

MIT
