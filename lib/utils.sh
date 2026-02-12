#!/bin/bash
# Utility functions for the project scaffolding tool

# Colors (disabled if not a terminal)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' BOLD='' NC=''
fi

log_info() {
    echo -e "${BLUE}INFO${NC}  $*"
}

log_ok() {
    echo -e "${GREEN}OK${NC}    $*"
}

log_warn() {
    echo -e "${YELLOW}WARN${NC}  $*"
}

log_error() {
    echo -e "${RED}ERROR${NC} $*" >&2
}

log_step() {
    echo -e "${BOLD}==> $*${NC}"
}

# Check if a command exists
require_cmd() {
    local cmd="$1"
    local install_hint="$2"
    if ! command -v "$cmd" &>/dev/null; then
        log_error "'$cmd' is not installed."
        [ -n "$install_hint" ] && log_error "  Install: $install_hint"
        exit 1
    fi
}

# Render a template file by replacing {{PLACEHOLDER}} with values
# Usage: render_template <template_file> <output_file>
# Expects TMPL_VARS associative array to be declared by caller
render_template() {
    local src="$1"
    local dst="$2"

    if [ ! -f "$src" ]; then
        log_warn "Template not found: $src"
        return 1
    fi

    local content
    content=$(<"$src")

    for key in "${!TMPL_VARS[@]}"; do
        content="${content//\{\{$key\}\}/${TMPL_VARS[$key]}}"
    done

    echo "$content" > "$dst"
}

# Render a template string (from stdin or argument) with TMPL_VARS substitution
render_string() {
    local content="$1"
    for key in "${!TMPL_VARS[@]}"; do
        content="${content//\{\{$key\}\}/${TMPL_VARS[$key]}}"
    done
    echo "$content"
}

# Check if a value exists in a space-separated list
list_contains() {
    local list="$1"
    local item="$2"
    [[ " $list " == *" $item "* ]]
}

# Ensure a directory exists
ensure_dir() {
    mkdir -p "$1"
}
