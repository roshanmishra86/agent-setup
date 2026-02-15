#!/usr/bin/env bats
# Tests for lib/parse_config.sh — YAML parsing, merging, and accessor helpers.

setup() {
    # shellcheck source=../lib/utils.sh
    source "$BATS_TEST_DIRNAME/../lib/utils.sh"
    # shellcheck source=../lib/parse_config.sh
    source "$BATS_TEST_DIRNAME/../lib/parse_config.sh"

    # Fresh config array for each test
    declare -gA CFG
    declare -gA TMPL_VARS
    declare -ga ENABLED_FLAGS

    TEST_TMP="$(mktemp -d)"
}

teardown() {
    rm -rf "$TEST_TMP"
}

# ── parse_yaml ─────────────────────────────────────────────────────

@test "parse_yaml reads scalar values" {
    cat > "$TEST_TMP/config.yml" <<'EOF'
project:
  name: "test-project"
  author: "Jane Doe"
coding:
  style: "functional"
EOF
    parse_yaml "$TEST_TMP/config.yml"
    [ "${CFG[project.name]}" = "test-project" ]
    [ "${CFG[project.author]}" = "Jane Doe" ]
    [ "${CFG[coding.style]}" = "functional" ]
}

@test "parse_yaml reads list values as comma-separated strings" {
    cat > "$TEST_TMP/config.yml" <<'EOF'
agents:
  generate:
    - claude
    - cursor
    - gemini
EOF
    parse_yaml "$TEST_TMP/config.yml"
    [ "${CFG[agents.generate]}" = "claude,cursor,gemini" ]
}

@test "parse_yaml strips inline comments" {
    cat > "$TEST_TMP/config.yml" <<'EOF'
coding:
  style: "functional"    # main style
  comments: "minimal"    # keep it short
EOF
    parse_yaml "$TEST_TMP/config.yml"
    [ "${CFG[coding.style]}" = "functional" ]
    [ "${CFG[coding.comments]}" = "minimal" ]
}

@test "parse_yaml skips blank lines and comments" {
    cat > "$TEST_TMP/config.yml" <<'EOF'
# This is a comment
project:
  name: "test"

  # Another comment
  author: "Bob"
EOF
    parse_yaml "$TEST_TMP/config.yml"
    [ "${CFG[project.name]}" = "test" ]
    [ "${CFG[project.author]}" = "Bob" ]
}

@test "parse_yaml returns error for missing file" {
    run parse_yaml "$TEST_TMP/nonexistent.yml"
    [ "$status" -eq 1 ]
}

# ── merge_yaml ─────────────────────────────────────────────────────

@test "merge_yaml overrides existing values" {
    cat > "$TEST_TMP/base.yml" <<'EOF'
project:
  name: "base-project"
coding:
  style: "functional"
EOF
    cat > "$TEST_TMP/override.yml" <<'EOF'
project:
  name: "overridden"
EOF
    parse_yaml "$TEST_TMP/base.yml"
    merge_yaml "$TEST_TMP/override.yml"
    [ "${CFG[project.name]}" = "overridden" ]
    [ "${CFG[coding.style]}" = "functional" ]
}

# ── cfg_get / cfg_is ───────────────────────────────────────────────

@test "cfg_get returns value when key exists" {
    CFG[project.name]="hello"
    result="$(cfg_get project.name "default")"
    [ "$result" = "hello" ]
}

@test "cfg_get returns default when key missing" {
    result="$(cfg_get nonexistent.key "fallback")"
    [ "$result" = "fallback" ]
}

@test "cfg_is returns true for matching value" {
    CFG[ci.enabled]="true"
    cfg_is ci.enabled true
}

@test "cfg_is returns false for non-matching value" {
    CFG[ci.enabled]="false"
    ! cfg_is ci.enabled true
}

# ── agent_enabled ──────────────────────────────────────────────────

@test "agent_enabled finds agent in comma-separated list" {
    CFG[agents.generate]="claude,cursor,gemini"
    agent_enabled "cursor"
}

@test "agent_enabled returns false for missing agent" {
    CFG[agents.generate]="claude,cursor"
    ! agent_enabled "gemini"
}

@test "agent_enabled handles single agent" {
    CFG[agents.generate]="agents_md"
    agent_enabled "agents_md"
}
