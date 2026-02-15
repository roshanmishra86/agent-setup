#!/usr/bin/env bats
# Tests for conditional processing and template substitution (utils.sh).

setup() {
    # shellcheck source=../lib/utils.sh
    source "$BATS_TEST_DIRNAME/../lib/utils.sh"

    declare -gA TMPL_VARS
    declare -ga ENABLED_FLAGS
}

# ── flag_enabled ───────────────────────────────────────────────────

@test "flag_enabled returns true for present flag" {
    ENABLED_FLAGS=(STYLE_FUNCTIONAL TDD_STRICT)
    flag_enabled "STYLE_FUNCTIONAL"
}

@test "flag_enabled returns false for absent flag" {
    ENABLED_FLAGS=(STYLE_FUNCTIONAL)
    ! flag_enabled "TDD_STRICT"
}

@test "flag_enabled rejects partial matches" {
    ENABLED_FLAGS=(STYLE_FUNCTIONAL)
    ! flag_enabled "STYLE"
}

# ── process_conditionals ──────────────────────────────────────────

@test "process_conditionals keeps block when flag is enabled" {
    ENABLED_FLAGS=(TDD_STRICT)
    local input=$'line1\n{{#TDD_STRICT}}\nkept line\n{{/TDD_STRICT}}\nline2'
    local result
    result="$(process_conditionals "$input")"
    [[ "$result" == *"kept line"* ]]
    [[ "$result" == *"line1"* ]]
    [[ "$result" == *"line2"* ]]
}

@test "process_conditionals removes block when flag is disabled" {
    ENABLED_FLAGS=()
    local input=$'line1\n{{#TDD_STRICT}}\nremoved line\n{{/TDD_STRICT}}\nline2'
    local result
    result="$(process_conditionals "$input")"
    [[ "$result" != *"removed line"* ]]
    [[ "$result" == *"line1"* ]]
    [[ "$result" == *"line2"* ]]
}

@test "process_conditionals handles inline conditionals (enabled)" {
    ENABLED_FLAGS=(TOOLING_JS)
    local input='Use {{#TOOLING_JS}}bun test{{/TOOLING_JS}} to run'
    local result
    result="$(process_conditionals "$input")"
    [[ "$result" == *"Use bun test to run"* ]]
}

@test "process_conditionals handles inline conditionals (disabled)" {
    ENABLED_FLAGS=()
    local input='Use {{#TOOLING_JS}}bun test{{/TOOLING_JS}} to run'
    local result
    result="$(process_conditionals "$input")"
    [[ "$result" == *"Use  to run"* ]]
}

# ── substitute_vars ───────────────────────────────────────────────

@test "substitute_vars replaces placeholders" {
    TMPL_VARS[PROJECT_NAME]="my-app"
    TMPL_VARS[COVERAGE_THRESHOLD]="90"
    local result
    result="$(substitute_vars "Project: {{PROJECT_NAME}}, coverage: {{COVERAGE_THRESHOLD}}%")"
    [ "$result" = "Project: my-app, coverage: 90%" ]
}

@test "substitute_vars leaves unknown placeholders unchanged" {
    TMPL_VARS=()
    local result
    result="$(substitute_vars "Hello {{UNKNOWN}}")"
    [ "$result" = "Hello {{UNKNOWN}}" ]
}

# ── render_template ───────────────────────────────────────────────

@test "render_template writes processed content to file" {
    local tmp
    tmp="$(mktemp -d)"
    echo "Hello {{NAME}}" > "$tmp/input.tmpl"
    TMPL_VARS[NAME]="World"
    render_template "$tmp/input.tmpl" "$tmp/output.txt"
    [ "$(cat "$tmp/output.txt")" = "Hello World" ]
    rm -rf "$tmp"
}

@test "render_template returns error for missing source" {
    local tmp
    tmp="$(mktemp -d)"
    run render_template "$tmp/nonexistent.tmpl" "$tmp/output.txt"
    [ "$status" -eq 1 ]
    rm -rf "$tmp"
}

# ── render_processed_template ─────────────────────────────────────

@test "render_processed_template processes conditionals and vars" {
    local tmp
    tmp="$(mktemp -d)"
    ENABLED_FLAGS=(FEATURE_ON)
    TMPL_VARS[PROJECT]="demo"
    cat > "$tmp/input.tmpl" <<'EOF'
# {{PROJECT}}
{{#FEATURE_ON}}
Feature is enabled
{{/FEATURE_ON}}
{{#FEATURE_OFF}}
Feature is disabled
{{/FEATURE_OFF}}
EOF
    render_processed_template "$tmp/input.tmpl" "$tmp/output.txt"
    local result
    result="$(cat "$tmp/output.txt")"
    [[ "$result" == *"# demo"* ]]
    [[ "$result" == *"Feature is enabled"* ]]
    [[ "$result" != *"Feature is disabled"* ]]
    rm -rf "$tmp"
}
