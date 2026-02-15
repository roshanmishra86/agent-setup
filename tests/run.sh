#!/bin/bash
# Run all BATS tests.
# Usage: ./tests/run.sh
#
# Prerequisites:
#   bats  — https://github.com/bats-core/bats-core
#
# Install (Linux/macOS):
#   bun install -g bats
#   # or: brew install bats-core

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v bats &>/dev/null; then
    echo "ERROR: 'bats' not found. Install: bun install -g bats"
    exit 1
fi

echo "Running BATS tests..."
echo ""

bats "$SCRIPT_DIR"/*.bats

echo ""
echo "All tests passed."
