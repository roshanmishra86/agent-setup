#!/usr/bin/env bats
# Tests for build.sh CLI argument parsing and validation.

setup() {
    SCRIPT_DIR="$BATS_TEST_DIRNAME/.."
    BUILD="$SCRIPT_DIR/build.sh"
}

# ── Help ───────────────────────────────────────────────────────────

@test "build.sh --help exits 0 and shows usage" {
    run bash "$BUILD" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
    [[ "$output" == *"--dry-run"* ]]
    [[ "$output" == *"--output-dir"* ]]
}

@test "build.sh -h exits 0" {
    run bash "$BUILD" -h
    [ "$status" -eq 0 ]
}

# ── Missing required args ─────────────────────────────────────────

@test "build.sh without project type fails" {
    run bash "$BUILD" -n test-proj
    [ "$status" -eq 1 ]
    [[ "$output" == *"Project type not specified"* ]]
}

@test "build.sh without project name fails" {
    run bash "$BUILD" js
    [ "$status" -eq 1 ]
    [[ "$output" == *"Project name is required"* ]]
}

# ── Argument validation for shift 2 ───────────────────────────────

@test "build.sh -n without value fails with helpful message" {
    run bash "$BUILD" js -n
    [ "$status" -eq 1 ]
    [[ "$output" == *"requires an argument"* ]]
}

@test "build.sh -c without value fails" {
    run bash "$BUILD" js -n test -c
    [ "$status" -eq 1 ]
    [[ "$output" == *"requires an argument"* ]]
}

@test "build.sh --agents without value fails" {
    run bash "$BUILD" js -n test --agents
    [ "$status" -eq 1 ]
    [[ "$output" == *"requires an argument"* ]]
}

@test "build.sh --output-dir without value fails" {
    run bash "$BUILD" js -n test -o
    [ "$status" -eq 1 ]
    [[ "$output" == *"requires an argument"* ]]
}

# ── Unknown option ─────────────────────────────────────────────────

@test "build.sh with unknown option fails" {
    run bash "$BUILD" js -n test --foo
    [ "$status" -eq 1 ]
    [[ "$output" == *"Unknown option"* ]]
}

# ── Existing directory guard ───────────────────────────────────────

@test "build.sh refuses to overwrite non-empty directory" {
    local tmp
    tmp="$(mktemp -d)"
    mkdir -p "$tmp/existing-project"
    echo "content" > "$tmp/existing-project/file.txt"
    run bash "$BUILD" js -n existing-project -o "$tmp"
    [ "$status" -eq 1 ]
    [[ "$output" == *"already exists and is not empty"* ]]
    rm -rf "$tmp"
}
