#!/bin/bash
# Assembles AGENTS.md from modular rule templates with config-driven substitution.


# Build the list of enabled conditional flags based on config
build_enabled_flags() {
    ENABLED_FLAGS=()

    # Coding style
    local style
    style="$(cfg_get coding.style functional)"
    case "$style" in
        functional) ENABLED_FLAGS+=(STYLE_FUNCTIONAL) ;;
        classes)    ENABLED_FLAGS+=(STYLE_CLASSES) ;;
        mixed)      ENABLED_FLAGS+=(STYLE_MIXED) ;;
    esac

    # Comments
    local comments
    comments="$(cfg_get coding.comments minimal)"
    case "$comments" in
        minimal)  ENABLED_FLAGS+=(COMMENTS_MINIMAL) ;;
        moderate) ENABLED_FLAGS+=(COMMENTS_MODERATE) ;;
    esac

    # Testing philosophy
    local testing
    testing="$(cfg_get testing.philosophy tdd-strict)"
    case "$testing" in
        tdd-strict)  ENABLED_FLAGS+=(TDD_STRICT) ;;
        tdd-relaxed) ENABLED_FLAGS+=(TDD_RELAXED) ;;
        test-after)  ENABLED_FLAGS+=(TEST_AFTER) ;;
    esac

    # Integration/E2E test requirements
    cfg_is testing.require_integration_tests true && ENABLED_FLAGS+=(REQUIRE_INTEGRATION)
    cfg_is testing.require_e2e_tests true && ENABLED_FLAGS+=(REQUIRE_E2E)

    # Commit format
    local commit
    commit="$(cfg_get version_control.commit_format conventional)"
    case "$commit" in
        conventional) ENABLED_FLAGS+=(COMMIT_CONVENTIONAL) ;;
        simple)       ENABLED_FLAGS+=(COMMIT_SIMPLE) ;;
        gitmoji)      ENABLED_FLAGS+=(COMMIT_GITMOJI) ;;
    esac

    # Pre-commit hooks
    cfg_is version_control.pre_commit_hooks true && ENABLED_FLAGS+=(PRE_COMMIT_ENABLED)

    # Language-specific tooling
    if [ "$PROJECT_TYPE" = "js" ]; then
        ENABLED_FLAGS+=(TOOLING_JS)

        local js_linter js_formatter
        js_linter="$(cfg_get lint.js.linter biome)"
        js_formatter="$(cfg_get lint.js.formatter biome)"

        case "$js_linter" in
            biome)  ENABLED_FLAGS+=(LINT_BIOME) ;;
            eslint) ENABLED_FLAGS+=(LINT_ESLINT) ;;
        esac
        [ "$js_formatter" = "prettier" ] && ENABLED_FLAGS+=(FORMAT_PRETTIER)
    fi

    if [ "$PROJECT_TYPE" = "py" ]; then
        ENABLED_FLAGS+=(TOOLING_PY)

        local py_linter py_formatter py_type
        py_linter="$(cfg_get lint.py.linter ruff)"
        py_formatter="$(cfg_get lint.py.formatter ruff)"
        py_type="$(cfg_get lint.py.type_checker mypy)"

        case "$py_linter" in
            ruff)   ENABLED_FLAGS+=(LINT_RUFF) ;;
            flake8) ENABLED_FLAGS+=(LINT_FLAKE8) ;;
        esac
        [ "$py_formatter" = "black" ] && ENABLED_FLAGS+=(FORMAT_BLACK)

        case "$py_type" in
            mypy)    ENABLED_FLAGS+=(TYPE_MYPY) ;;
            pyright) ENABLED_FLAGS+=(TYPE_PYRIGHT) ;;
        esac
    fi
}

# Build TMPL_VARS for placeholder substitution
build_template_vars() {
    TMPL_VARS[PROJECT_NAME]="$(cfg_get project.name "$PROJECT_NAME")"
    TMPL_VARS[PROJECT_AUTHOR]="$(cfg_get project.author "")"
    TMPL_VARS[PROJECT_DESCRIPTION]="$(cfg_get project.description "")"
    TMPL_VARS[CODING_STYLE]="$(cfg_get coding.style functional)"
    TMPL_VARS[MAX_FUNCTION_LINES]="$(cfg_get coding.max_function_lines 50)"
    TMPL_VARS[COVERAGE_THRESHOLD]="$(cfg_get testing.coverage_threshold 80)"
    TMPL_VARS[PY_RUNNER]="uv run"

    # Build lint/format/type commands for CI gate
    if [ "$PROJECT_TYPE" = "js" ]; then
        local js_linter
        js_linter="$(cfg_get lint.js.linter biome)"
        case "$js_linter" in
            biome)  TMPL_VARS[JS_LINT_CMD]="bunx biome check ." ;;
            eslint) TMPL_VARS[JS_LINT_CMD]="bunx eslint ." ;;
        esac
    fi

    if [ "$PROJECT_TYPE" = "py" ]; then
        local py_linter py_formatter py_type
        py_linter="$(cfg_get lint.py.linter ruff)"
        py_formatter="$(cfg_get lint.py.formatter ruff)"
        py_type="$(cfg_get lint.py.type_checker mypy)"

        case "$py_linter" in
            ruff)   TMPL_VARS[PY_LINT_CMD]="uv run ruff check ." ;;
            flake8) TMPL_VARS[PY_LINT_CMD]="uv run flake8 ." ;;
        esac
        case "$py_formatter" in
            ruff)  TMPL_VARS[PY_FORMAT_CMD]="uv run ruff format --check ." ;;
            black) TMPL_VARS[PY_FORMAT_CMD]="uv run black --check ." ;;
        esac
        case "$py_type" in
            mypy)    TMPL_VARS[PY_TYPE_CMD]="uv run mypy ." ;;
            pyright) TMPL_VARS[PY_TYPE_CMD]="uv run pyright ." ;;
        esac
    fi
}

# Process a single rule template file: conditionals + variable substitution
process_rule() {
    local file="$1"
    if [ ! -f "$file" ]; then
        return
    fi
    local raw
    raw=$(<"$file")
    local processed
    processed="$(process_conditionals "$raw")"
    processed="$(substitute_vars "$processed")"
    echo "$processed"
}

# Main: generate AGENTS.md in the target project directory
generate_agents_md() {
    local project_dir="$1"
    local template_dir="$2"
    local rules_dir="$template_dir/rules"

    build_enabled_flags
    build_template_vars

    log_step "Generating AGENTS.md"

    local output=""

    # Header
    local pname pauthor pdesc
    pname="$(cfg_get project.name "$PROJECT_NAME")"
    pauthor="$(cfg_get project.author "")"
    pdesc="$(cfg_get project.description "")"

    output+="# ${pname} — Development Guidelines"$'\n'
    output+=$'\n'
    [ -n "$pdesc" ] && output+="${pdesc}"$'\n\n'
    [ -n "$pauthor" ] && output+="**Author:** ${pauthor}"$'\n\n'
    output+="These guidelines apply to all AI coding assistants and human developers working on this project."$'\n'
    output+=$'\n---\n\n'

    # Assemble rules
    output+="$(process_rule "$rules_dir/coding-style.md")"$'\n'
    output+="$(process_rule "$rules_dir/testing.md")"$'\n'

    # Tooling — language-specific
    if [ "$PROJECT_TYPE" = "js" ]; then
        output+="$(process_rule "$rules_dir/tooling-js.md")"$'\n'
    elif [ "$PROJECT_TYPE" = "py" ]; then
        output+="$(process_rule "$rules_dir/tooling-py.md")"$'\n'
    fi

    output+="$(process_rule "$rules_dir/version-control.md")"$'\n'
    output+="$(process_rule "$rules_dir/debugging.md")"$'\n'
    output+="$(process_rule "$rules_dir/task-management.md")"$'\n'
    output+="$(process_rule "$rules_dir/code-organization.md")"$'\n'
    output+="$(process_rule "$rules_dir/code-review.md")"$'\n'

    # Custom rules from config
    local custom_rules
    custom_rules="$(cfg_get custom_rules "")"
    if [ -n "$custom_rules" ]; then
        output+="## Custom Rules"$'\n\n'
        IFS=',' read -ra rules <<< "$custom_rules"
        for rule in "${rules[@]}"; do
            rule="$(echo "$rule" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
            [ -n "$rule" ] && output+="- ${rule}"$'\n'
        done
        output+=$'\n'
    fi

    echo "$output" > "$project_dir/AGENTS.md"
    log_ok "AGENTS.md generated"
}
