#!/bin/bash
# Generates project-level MCP server config files for each supported tool.
#
# Each tool has its own file path and JSON format:
#   Claude Code  → .mcp.json               (mcpServers, standard format)
#   Cursor       → .cursor/mcp.json        (mcpServers, standard format)
#   Gemini CLI   → .gemini/settings.json   (mcpServers, standard format)
#   OpenCode     → opencode.json           (mcp.server-name.type/command, opencode format)
#
# Codex and Antigravity use global MCP config only (no project-level file).

generate_mcp() {
    local project_dir="$1"

    # Collect enabled server names for each format
    local -a std_entries=()     # Standard mcpServers format
    local -a oc_entries=()      # OpenCode format

    if cfg_is "mcps.context7" "true"; then
        std_entries+=("$(mcp_std_npx "context7" "@upstash/context7-mcp")")
        oc_entries+=("$(mcp_oc_npx "context7" "@upstash/context7-mcp")")
    fi

    if cfg_is "mcps.playwright" "true"; then
        std_entries+=("$(mcp_std_npx "playwright" "@playwright/mcp@latest")")
        oc_entries+=("$(mcp_oc_npx "playwright" "@playwright/mcp@latest")")
    fi

    if cfg_is "mcps.sequential-thinking" "true"; then
        std_entries+=("$(mcp_std_npx "sequential-thinking" "@modelcontextprotocol/server-sequential-thinking")")
        oc_entries+=("$(mcp_oc_npx "sequential-thinking" "@modelcontextprotocol/server-sequential-thinking")")
    fi

    if cfg_is "mcps.tavily" "true"; then
        std_entries+=("$(mcp_std_npx_env "tavily" "tavily-mcp@latest" "TAVILY_API_KEY" "\${TAVILY_API_KEY}")")
        oc_entries+=("$(mcp_oc_npx_env "tavily" "tavily-mcp@latest" "TAVILY_API_KEY" "\${TAVILY_API_KEY}")")
    fi

    # Skip if no servers are enabled
    if [ ${#std_entries[@]} -eq 0 ]; then
        return
    fi

    log_step "Generating MCP config"

    local std_json oc_json
    std_json="$(build_std_json "${std_entries[@]}")"
    oc_json="$(build_oc_json "${oc_entries[@]}")"

    # Claude Code: .mcp.json
    if agent_enabled "claude"; then
        echo "$std_json" > "$project_dir/.mcp.json"
        log_ok ".mcp.json"
    fi

    # Cursor: .cursor/mcp.json
    if agent_enabled "cursor"; then
        ensure_dir "$project_dir/.cursor"
        echo "$std_json" > "$project_dir/.cursor/mcp.json"
        log_ok ".cursor/mcp.json"
    fi

    # Gemini CLI: .gemini/settings.json
    if agent_enabled "gemini"; then
        ensure_dir "$project_dir/.gemini"
        echo "$std_json" > "$project_dir/.gemini/settings.json"
        log_ok ".gemini/settings.json"
    fi

    # OpenCode: opencode.json
    if agent_enabled "opencode"; then
        echo "$oc_json" > "$project_dir/opencode.json"
        log_ok "opencode.json"
    fi
}

# ── Standard mcpServers format (Claude Code, Cursor, Gemini CLI) ──────────────

build_std_json() {
    local -a entries=("$@")
    local body="" sep=""
    for entry in "${entries[@]}"; do
        body="${body}${sep}${entry}"
        sep=","
    done
    printf '{\n  "mcpServers": {\n%s\n  }\n}\n' "$body"
}

# npx entry, no env vars
mcp_std_npx() {
    local name="$1" pkg="$2"
    printf '    "%s": {\n      "command": "npx",\n      "args": ["-y", "%s"]\n    }' "$name" "$pkg"
}

# npx entry with one env var
mcp_std_npx_env() {
    local name="$1" pkg="$2" env_key="$3" env_val="$4"
    printf '    "%s": {\n      "command": "npx",\n      "args": ["-y", "%s"],\n      "env": {\n        "%s": "%s"\n      }\n    }' \
        "$name" "$pkg" "$env_key" "$env_val"
}

# ── OpenCode format (opencode.json) ───────────────────────────────────────────

build_oc_json() {
    local -a entries=("$@")
    local body="" sep=""
    for entry in "${entries[@]}"; do
        body="${body}${sep}${entry}"
        sep=","
    done
    printf '{\n  "$schema": "https://opencode.ai/config.json",\n  "mcp": {\n%s\n  }\n}\n' "$body"
}

# npx entry, no env vars
mcp_oc_npx() {
    local name="$1" pkg="$2"
    printf '    "%s": {\n      "type": "local",\n      "command": ["npx", "-y", "%s"],\n      "enabled": true\n    }' "$name" "$pkg"
}

# npx entry with one env var
mcp_oc_npx_env() {
    local name="$1" pkg="$2" env_key="$3" env_val="$4"
    printf '    "%s": {\n      "type": "local",\n      "command": ["npx", "-y", "%s"],\n      "enabled": true,\n      "environment": {\n        "%s": "%s"\n      }\n    }' \
        "$name" "$pkg" "$env_key" "$env_val"
}
