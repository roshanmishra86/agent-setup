#!/bin/bash
# Generates .mcp.json and .cursor/mcp.json for project-level MCP server config.
# Both files use the standard mcpServers format recognised by Claude Code, Cursor,
# Windsurf, Cline, and other MCP-compatible tools.

generate_mcp() {
    local project_dir="$1"

    # Collect enabled servers
    local -a entries=()

    if cfg_is "mcps.context7" "true"; then
        entries+=("$(mcp_entry_npx "context7" "@upstash/context7-mcp")")
    fi

    if cfg_is "mcps.playwright" "true"; then
        entries+=("$(mcp_entry_npx "playwright" "@playwright/mcp@latest")")
    fi

    if cfg_is "mcps.sequential-thinking" "true"; then
        entries+=("$(mcp_entry_npx "sequential-thinking" "@modelcontextprotocol/server-sequential-thinking")")
    fi

    if cfg_is "mcps.tavily" "true"; then
        entries+=("$(mcp_entry_npx_env "tavily" "tavily-mcp@latest" "TAVILY_API_KEY" "\${TAVILY_API_KEY}")")
    fi

    # Nothing enabled — skip file generation
    if [ ${#entries[@]} -eq 0 ]; then
        return
    fi

    log_step "Generating MCP config"

    local json
    json="$(build_mcp_json "${entries[@]}")"

    # .mcp.json — Claude Code project-level config
    echo "$json" > "$project_dir/.mcp.json"
    log_ok ".mcp.json"

    # .cursor/mcp.json — Cursor project-level config (identical format)
    ensure_dir "$project_dir/.cursor"
    echo "$json" > "$project_dir/.cursor/mcp.json"
    log_ok ".cursor/mcp.json"
}

# Build the full mcpServers JSON from an array of server entry strings.
build_mcp_json() {
    local -a entries=("$@")
    local body=""
    local sep=""

    for entry in "${entries[@]}"; do
        body="${body}${sep}${entry}"
        sep=","
    done

    printf '{\n  "mcpServers": {\n%s\n  }\n}\n' "$body"
}

# npx server entry (no env vars required)
# Usage: mcp_entry_npx <name> <package>
mcp_entry_npx() {
    local name="$1"
    local pkg="$2"
    printf '    "%s": {\n      "command": "npx",\n      "args": ["-y", "%s"]\n    }' "$name" "$pkg"
}

# npx server entry with a single env var
# Usage: mcp_entry_npx_env <name> <package> <env_key> <env_value>
mcp_entry_npx_env() {
    local name="$1"
    local pkg="$2"
    local env_key="$3"
    local env_val="$4"
    printf '    "%s": {\n      "command": "npx",\n      "args": ["-y", "%s"],\n      "env": {\n        "%s": "%s"\n      }\n    }' \
        "$name" "$pkg" "$env_key" "$env_val"
}
