#!/bin/bash
# Universal AI Agent Project Scaffolding Tool
# Generates projects with configs for all major AI coding agents.

set -e

# ── Paths ──────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/templates"
DEFAULT_CONFIG="$SCRIPT_DIR/config.default.yml"

# ── Source library modules ─────────────────────────────────────────
source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/parse_config.sh"
source "$SCRIPT_DIR/lib/generate_agents.sh"
source "$SCRIPT_DIR/lib/generate_agent_configs.sh"
source "$SCRIPT_DIR/lib/generate_ci.sh"
source "$SCRIPT_DIR/lib/generate_precommit.sh"
source "$SCRIPT_DIR/lib/generate_readme.sh"
source "$SCRIPT_DIR/lib/generate_mcp.sh"
source "$SCRIPT_DIR/lib/generate_cli.sh"

# ── Defaults ───────────────────────────────────────────────────────
PROJECT_NAME=""
PROJECT_TYPE=""
USER_CONFIG=""
FLAG_NO_CI=false
FLAG_NO_HOOKS=false
FLAG_AGENTS=""
FLAG_DRY_RUN=false
OUTPUT_DIR=""

# ── Globals ────────────────────────────────────────────────────────
declare -A CFG
declare -A TMPL_VARS
declare -a ENABLED_FLAGS

# ── CLI parsing ────────────────────────────────────────────────────
show_help() {
    cat <<'USAGE'
Usage: build.sh <js|py> -n <name> [options]

Creates a new project with AI agent configurations, CI, and pre-commit hooks.

Arguments:
  js                    Create a JavaScript/TypeScript project (requires bun)
  py                    Create a Python project (requires uv)

Options:
  -n, --name NAME       Project name (required)
  -c, --config FILE     Path to config.yml (overrides config.default.yml)
  -o, --output-dir DIR  Parent directory for the project (default: current dir)
  --no-ci               Skip CI workflow generation
  --no-hooks            Skip pre-commit hook generation
  --dry-run             Show what files would be generated without creating them
  --agents LIST         Comma-separated list of agents to generate
                        (default: all from config)
                        Available: agents_md,opencode,claude,codex,copilot,
                                   antigravity,cursor,gemini
  -h, --help            Show this help message

Examples:
  build.sh js -n my-app
  build.sh py -n my-api -c config.yml
  build.sh js -n my-app --no-ci --agents opencode,claude,cursor
  build.sh js -n my-app --dry-run
  build.sh js -n my-app -o ~/projects
USAGE
}

# Helper: validate that an option has a required argument
require_arg() {
    if [ -z "${2:-}" ] || [[ "$2" == -* ]]; then
        log_error "Option '$1' requires an argument."
        exit 1
    fi
}

while [[ $# -gt 0 ]]; do
    case $1 in
        js)           PROJECT_TYPE="js";  shift ;;
        py)           PROJECT_TYPE="py";  shift ;;
        -n|--name)    require_arg "$1" "${2:-}"; PROJECT_NAME="$2";  shift 2 ;;
        -c|--config)  require_arg "$1" "${2:-}"; USER_CONFIG="$2";   shift 2 ;;
        -o|--output-dir) require_arg "$1" "${2:-}"; OUTPUT_DIR="$2"; shift 2 ;;
        --no-ci)      FLAG_NO_CI=true;    shift ;;
        --no-hooks)   FLAG_NO_HOOKS=true; shift ;;
        --dry-run)    FLAG_DRY_RUN=true;  shift ;;
        --agents)     require_arg "$1" "${2:-}"; FLAG_AGENTS="$2";   shift 2 ;;
        -h|--help)    show_help; exit 0 ;;
        *)
            log_error "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# ── Validation ─────────────────────────────────────────────────────
if [ -z "$PROJECT_TYPE" ]; then
    log_error "Project type not specified. Use 'js' or 'py'."
    echo "Use -h or --help for usage information"
    exit 1
fi

if [ -z "$PROJECT_NAME" ]; then
    log_error "Project name is required. Use -n <name>."
    echo "Use -h or --help for usage information"
    exit 1
fi

if [ ! -d "$TEMPLATE_DIR" ]; then
    log_error "Template directory not found: $TEMPLATE_DIR"
    exit 1
fi

# ── Load config ────────────────────────────────────────────────────
log_step "Loading configuration"

parse_yaml "$DEFAULT_CONFIG"

if [ -n "$USER_CONFIG" ]; then
    if [ ! -f "$USER_CONFIG" ]; then
        log_error "Config file not found: $USER_CONFIG"
        exit 1
    fi
    log_info "Merging user config: $USER_CONFIG"
    merge_yaml "$USER_CONFIG"
fi

# Apply CLI overrides
CFG[project.name]="$PROJECT_NAME"
$FLAG_NO_CI && CFG[ci.enabled]="false"
$FLAG_NO_HOOKS && CFG[version_control.pre_commit_hooks]="false"

if [ -n "$FLAG_AGENTS" ]; then
    # Replace the agents list with CLI-specified agents
    CFG[agents.generate]="$FLAG_AGENTS"
fi

# Always ensure agents_md is in the list (other agents depend on it)
if ! agent_enabled "agents_md"; then
    CFG[agents.generate]="agents_md,${CFG[agents.generate]}"
fi

log_ok "Config loaded (project: $PROJECT_NAME, type: $PROJECT_TYPE)"

# ── Check prerequisites ───────────────────────────────────────────
log_step "Checking prerequisites"
require_cmd git

if [ "$PROJECT_TYPE" = "js" ]; then
    require_cmd bun "curl -fsSL https://bun.sh/install | bash"
elif [ "$PROJECT_TYPE" = "py" ]; then
    require_cmd uv "curl -LsSf https://astral.sh/uv/install.sh | sh"
fi

log_ok "Prerequisites satisfied"

# ── Create project ─────────────────────────────────────────────────
if $FLAG_DRY_RUN; then
    PROJECT_DIR=$(mktemp -d)
    trap 'rm -rf "$PROJECT_DIR"' EXIT
    log_step "Dry run — previewing project: $PROJECT_NAME"
else
    target_base="."
    [ -n "$OUTPUT_DIR" ] && target_base="$OUTPUT_DIR"
    target_path="$target_base/$PROJECT_NAME"

    if [ -d "$target_path" ] && [ "$(ls -A "$target_path" 2>/dev/null)" ]; then
        log_error "Directory '$target_path' already exists and is not empty."
        exit 1
    fi

    log_step "Creating project: $PROJECT_NAME"
    mkdir -p "$target_path"
    PROJECT_DIR="$(cd "$target_path" && pwd)"
fi

# ── Init language toolchain ────────────────────────────────────────
init_toolchain() {
    pushd "$PROJECT_DIR" > /dev/null || return 1

    if [ "$PROJECT_TYPE" = "js" ]; then
        log_step "Initializing Bun project"
        bun init --yes
        mkdir -p src tests

        # Copy starter code
        if [ -f "$TEMPLATE_DIR/starter/js/src/main.ts" ]; then
            cp "$TEMPLATE_DIR/starter/js/src/main.ts" src/main.ts
        fi
        if [ -f "$TEMPLATE_DIR/starter/js/tests/main.test.ts" ]; then
            cp "$TEMPLATE_DIR/starter/js/tests/main.test.ts" tests/main.test.ts
        fi

        log_ok "Bun project initialized"

    elif [ "$PROJECT_TYPE" = "py" ]; then
        log_step "Initializing uv project"
        uv init --name "$PROJECT_NAME"
        mkdir -p src tests

        # Copy starter code
        if [ -f "$TEMPLATE_DIR/starter/py/src/main.py" ]; then
            cp "$TEMPLATE_DIR/starter/py/src/main.py" src/main.py
        fi
        if [ -f "$TEMPLATE_DIR/starter/py/tests/test_main.py" ]; then
            cp "$TEMPLATE_DIR/starter/py/tests/test_main.py" tests/test_main.py
        fi

        touch src/__init__.py tests/__init__.py
        log_ok "uv project initialized"
    fi

    popd > /dev/null || true
}

# ── Copy gitignore ─────────────────────────────────────────────────
setup_gitignore() {
    local gitignore_src="$TEMPLATE_DIR/gitignore/${PROJECT_TYPE}.gitignore"
    if [ -f "$gitignore_src" ]; then
        cp "$gitignore_src" "$PROJECT_DIR/.gitignore"
        log_ok ".gitignore"
    else
        log_warn "No .gitignore template found for $PROJECT_TYPE"
    fi
}

# ── Copy universal commands ────────────────────────────────────────
setup_commands() {
    local cmd_src="$TEMPLATE_DIR/commands"
    if [ -d "$cmd_src" ]; then
        log_step "Copying workflow commands"
        local cmd_dst="$PROJECT_DIR/.agents/commands"
        ensure_dir "$cmd_dst"
        cp "$cmd_src"/*.md "$cmd_dst/"
        log_ok ".agents/commands/"
    fi
}

# ── Copy Claude Code skills ────────────────────────────────────────
setup_skills() {
    local skills_src="$TEMPLATE_DIR/skills"
    if [ -d "$skills_src" ]; then
        log_step "Copying Claude Code skills"
        local skills_dst="$PROJECT_DIR/.claude/commands"
        ensure_dir "$skills_dst"
        # Copy each skill subdirectory
        for skill_dir in "$skills_src"/*/; do
            if [ -d "$skill_dir" ]; then
                local skill_name
                skill_name="$(basename "$skill_dir")"
                ensure_dir "$skills_dst/$skill_name"
                cp "$skill_dir"/* "$skills_dst/$skill_name/"
            fi
        done
        log_ok ".claude/commands/"
    fi
}

# ── Install dev dependencies ───────────────────────────────────────
install_dependencies() {
    pushd "$PROJECT_DIR" > /dev/null || return 1

    if [ "$PROJECT_TYPE" = "js" ]; then
        log_step "Installing dev dependencies"
        bun add -d typescript @types/bun
        bun install
        log_ok "Dependencies installed"

    elif [ "$PROJECT_TYPE" = "py" ]; then
        log_step "Installing dev dependencies"

        local py_linter py_formatter py_type
        py_linter="$(cfg_get lint.py.linter ruff)"
        py_formatter="$(cfg_get lint.py.formatter ruff)"
        py_type="$(cfg_get lint.py.type_checker mypy)"

        # shellcheck disable=SC2206  # intentional word splitting
        local deps=(pytest pytest-cov "$py_linter")
        [ "$py_formatter" != "$py_linter" ] && deps+=("$py_formatter")
        deps+=("$py_type")

        uv add --dev "${deps[@]}"
        uv sync
        log_ok "Dependencies installed"
    fi

    popd > /dev/null || true
}

# ── Git init + commit ──────────────────────────────────────────────
init_git() {
    pushd "$PROJECT_DIR" > /dev/null || return 1
    log_step "Initializing git repository"
    git init
    git add .
    git commit -m "feat: initial project setup with universal agent configs"
    log_ok "Git repository initialized with initial commit"
    popd > /dev/null || true
}

# ── Print summary ─────────────────────────────────────────────────
print_summary() {
    local agents_list
    agents_list="$(cfg_get agents.generate "")"

    echo ""
    echo "================================================================"
    echo "  Project '$PROJECT_NAME' created successfully!"
    echo "================================================================"
    echo ""
    echo "  Type:      $PROJECT_TYPE"
    echo "  Location:  $PROJECT_DIR"
    echo "  Agents:    ${agents_list//,/, }"
    echo "  CI:        $(cfg_get ci.enabled true)"
    echo "  Hooks:     $(cfg_get version_control.pre_commit_hooks true)"
    echo "  Skills:    .claude/commands/"
    echo ""

    if [ "$PROJECT_TYPE" = "js" ]; then
        echo "  Next steps:"
        echo "    cd $PROJECT_NAME"
        echo "    bun src/main.ts"
        echo "    bun test"
    elif [ "$PROJECT_TYPE" = "py" ]; then
        echo "  Next steps:"
        echo "    cd $PROJECT_NAME"
        echo "    uv run python -m src.main"
        echo "    uv run pytest"
    fi

    echo ""
}

# ── Main execution ─────────────────────────────────────────────────
if ! $FLAG_DRY_RUN; then
    init_toolchain
fi

setup_gitignore
generate_agents_md "$PROJECT_DIR" "$TEMPLATE_DIR"
generate_agent_configs "$PROJECT_DIR" "$TEMPLATE_DIR"
setup_commands
setup_skills
generate_mcp "$PROJECT_DIR"
generate_ci "$PROJECT_DIR" "$TEMPLATE_DIR"
generate_precommit "$PROJECT_DIR" "$TEMPLATE_DIR"
generate_readme "$PROJECT_DIR" "$TEMPLATE_DIR"
generate_cli "$PROJECT_DIR" "$TEMPLATE_DIR"

if $FLAG_DRY_RUN; then
    echo ""
    log_step "Dry run — files that would be generated:"
    (cd "$PROJECT_DIR" && find . -type f | sort | sed 's|^\./|  |')
    exit 0
fi

install_dependencies
init_git
print_summary
