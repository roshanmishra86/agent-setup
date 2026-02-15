#!/bin/bash
# Run shellcheck on all shell scripts in the project.
# Usage: ./tests/shellcheck.sh
#
# Exit code: 0 if all files pass, 1 otherwise.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Running shellcheck..."

files=(
    "$SCRIPT_DIR/build.sh"
    "$SCRIPT_DIR/lib/utils.sh"
    "$SCRIPT_DIR/lib/parse_config.sh"
    "$SCRIPT_DIR/lib/generate_agents.sh"
    "$SCRIPT_DIR/lib/generate_agent_configs.sh"
    "$SCRIPT_DIR/lib/generate_ci.sh"
    "$SCRIPT_DIR/lib/generate_precommit.sh"
    "$SCRIPT_DIR/lib/generate_readme.sh"
    "$SCRIPT_DIR/lib/generate_mcp.sh"
    "$SCRIPT_DIR/lib/generate_cli.sh"
)

failed=0
for f in "${files[@]}"; do
    if shellcheck -x -e SC1091 "$f"; then
        echo "  OK  $(basename "$f")"
    else
        echo "  FAIL $(basename "$f")"
        failed=1
    fi
done

if [ "$failed" -eq 0 ]; then
    echo "All files passed shellcheck."
else
    echo "Some files have shellcheck warnings."
    exit 1
fi
