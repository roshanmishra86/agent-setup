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

# Replace {{PLACEHOLDER}} variables in a string using TMPL_VARS
substitute_vars() {
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

# Check if a flag is in the ENABLED_FLAGS array
flag_enabled() {
    [[ " ${ENABLED_FLAGS[*]} " == *" $1 "* ]]
}

# Process conditional blocks in content.
# Supports both block-level and inline conditionals:
#   Block:  {{#FLAG}}\n...content...\n{{/FLAG}}
#   Inline: text {{#FLAG}}inline content{{/FLAG}} more text
# If FLAG is in ENABLED_FLAGS, content is kept; otherwise removed.
process_conditionals() {
    local content="$1"
    local result=""
    local skip_flag=""   # non-empty when inside a disabled block

    local re_open='^[[:space:]]*[{][{]#([A-Z0-9_]+)[}][}][[:space:]]*$'
    local re_close='^[[:space:]]*[{][{]/([A-Z0-9_]+)[}][}][[:space:]]*$'
    local re_inline='[{][{]#([A-Z0-9_]+)[}][}]([^{]*)[{][{]/([A-Z0-9_]+)[}][}]'

    while IFS= read -r line; do
        if [[ "$line" =~ $re_open ]]; then
            local flag="${BASH_REMATCH[1]}"
            if flag_enabled "$flag"; then
                continue
            else
                skip_flag="$flag"
                continue
            fi
        fi

        if [[ "$line" =~ $re_close ]]; then
            local cflag="${BASH_REMATCH[1]}"
            if [ "$skip_flag" = "$cflag" ]; then
                skip_flag=""
            fi
            continue
        fi

        if [ -n "$skip_flag" ]; then
            continue
        fi

        if [[ "$line" == *'{{#'* ]]; then
            local processed_line="$line"
            while [[ "$processed_line" =~ $re_inline ]]; do
                local iflag="${BASH_REMATCH[1]}"
                local icontent="${BASH_REMATCH[2]}"
                local full_match="${BASH_REMATCH[0]}"
                if flag_enabled "$iflag"; then
                    processed_line="${processed_line/"$full_match"/$icontent}"
                else
                    processed_line="${processed_line/"$full_match"/}"
                fi
            done
            result+="$processed_line"$'\n'
        else
            result+="$line"$'\n'
        fi
    done <<< "$content"

    echo "$result"
}

# Process a template file: conditionals + variable substitution → write to destination
# Usage: render_processed_template <src> <dst>
render_processed_template() {
    local src="$1" dst="$2"
    if [ ! -f "$src" ]; then
        log_warn "Template not found: $src"
        return 1
    fi
    local content
    content=$(<"$src")
    content="$(process_conditionals "$content")"
    content="$(substitute_vars "$content")"
    echo "$content" > "$dst"
}
