#!/bin/bash
# Simple YAML parser for flat/nested config files.
# Produces a flat associative array with dot-notation keys.
# Only handles the subset of YAML used by config.default.yml:
#   scalar values, lists serialized as comma-separated strings.
# Limitations:
#   - Keys must be ASCII alphanumeric, underscore, or hyphen only
#   - Values with colons work only because the first colon is used as delimiter
#   - No support for nested maps-in-values, multi-line strings, or anchors
#   - Indentation must use spaces (2-space indent assumed for nesting depth)

# Declare the global config array (caller must `declare -A CFG` before sourcing)
# After parsing: CFG[project.name]="my-project", CFG[agents.generate]="agents_md,claude,cursor,..."

parse_yaml() {
    local file="$1"
    local prefix=""
    local line key val indent prev_indent=0

    if [ ! -f "$file" ]; then
        log_error "Config file not found: $file"
        return 1
    fi

    local stack=()
    local list_started=""  # tracks which list key we've started building

    while IFS= read -r line || [ -n "$line" ]; do
        # Skip blank lines and comments
        [[ "$line" =~ ^[[:space:]]*$ ]] && continue
        [[ "$line" =~ ^[[:space:]]*# ]] && continue

        # Calculate indent level (number of leading spaces / 2)
        local stripped="${line#"${line%%[![:space:]]*}"}"
        local leading="${line%%"$stripped"}"
        indent=${#leading}

        # Handle list items (  - value)
        if [[ "$stripped" =~ ^-[[:space:]]+(.*) ]]; then
            local list_val="${BASH_REMATCH[1]}"
            # Remove surrounding quotes
            list_val="${list_val%\"}"
            list_val="${list_val#\"}"
            list_val="${list_val%\'}"
            list_val="${list_val#\'}"

            # Build the current prefix from stack
            local list_key=""
            for s in "${stack[@]}"; do
                [ -n "$list_key" ] && list_key="${list_key}."
                list_key="${list_key}${s}"
            done

            # On first item of a new list, clear any previous value (for merge)
            if [ "$list_started" != "$list_key" ]; then
                CFG["$list_key"]="$list_val"
                list_started="$list_key"
            else
                CFG["$list_key"]="${CFG[$list_key]},${list_val}"
            fi
            continue
        else
            # Not a list item — reset list tracking
            list_started=""
        fi

        # Handle key: value or key: (section header)
        if [[ "$stripped" =~ ^([a-zA-Z_][a-zA-Z0-9_-]*):(.*)$ ]]; then
            key="${BASH_REMATCH[1]}"
            val="${BASH_REMATCH[2]}"
            val="${val#"${val%%[![:space:]]*}"}"  # trim leading spaces

            # Adjust stack based on indent
            # Pop stack entries that are at same or deeper indent
            local target_depth=$((indent / 2))
            while [ ${#stack[@]} -gt "$target_depth" ]; do
                unset 'stack[${#stack[@]}-1]'
            done

            if [ -z "$val" ]; then
                # Section header — push onto stack
                stack+=("$key")
            else
                # Scalar value — remove surrounding quotes and inline comments
                val="${val%%#*}"              # strip inline comments
                val="${val%"${val##*[![:space:]]}"}"  # trim trailing spaces
                val="${val%\"}"
                val="${val#\"}"
                val="${val%\'}"
                val="${val#\'}"

                # Build full dotted key
                local full_key=""
                for s in "${stack[@]}"; do
                    full_key="${full_key}${s}."
                done
                full_key="${full_key}${key}"

                CFG["$full_key"]="$val"
            fi
        fi
    done < "$file"
}

# Merge a second config file on top of existing CFG values
merge_yaml() {
    parse_yaml "$1"
}

# Get a config value with a default fallback
cfg_get() {
    local key="$1"
    local default="$2"
    echo "${CFG[$key]:-$default}"
}

# Check if a config value equals a specific string
cfg_is() {
    local key="$1"
    local expected="$2"
    [ "$(cfg_get "$key")" = "$expected" ]
}

# Check if an agent is in the agents.generate list
agent_enabled() {
    local agent="$1"
    local agents
    agents="$(cfg_get agents.generate)"
    [[ ",$agents," == *",$agent,"* ]]
}
