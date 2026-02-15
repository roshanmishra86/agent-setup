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
#
# Requires: jq (only when MCP servers are enabled)

generate_mcp() {
    local project_dir="$1"

    # Check if any MCP server is enabled
    local has_mcp=false
    cfg_is "mcps.context7" "true" && has_mcp=true
    cfg_is "mcps.playwright" "true" && has_mcp=true
    cfg_is "mcps.sequential-thinking" "true" && has_mcp=true
    cfg_is "mcps.tavily" "true" && has_mcp=true

    if ! $has_mcp; then
        return
    fi

    require_cmd jq "https://jqlang.github.io/jq/download/"

    log_step "Generating MCP config"

    # Build JSON using jq for proper escaping
    local std_json='{"mcpServers":{}}'
    local oc_json='{"$schema":"https://opencode.ai/config.json","mcp":{}}'

    if cfg_is "mcps.context7" "true"; then
        std_json=$(echo "$std_json" | jq \
            '.mcpServers.context7 = {"command":"npx","args":["-y","@upstash/context7-mcp"]}')
        oc_json=$(echo "$oc_json" | jq \
            '.mcp.context7 = {"type":"local","command":["npx","-y","@upstash/context7-mcp"],"enabled":true}')
    fi

    if cfg_is "mcps.playwright" "true"; then
        std_json=$(echo "$std_json" | jq \
            '.mcpServers.playwright = {"command":"npx","args":["-y","@playwright/mcp@latest"]}')
        oc_json=$(echo "$oc_json" | jq \
            '.mcp.playwright = {"type":"local","command":["npx","-y","@playwright/mcp@latest"],"enabled":true}')
    fi

    if cfg_is "mcps.sequential-thinking" "true"; then
        std_json=$(echo "$std_json" | jq \
            '.mcpServers["sequential-thinking"] = {"command":"npx","args":["-y","@modelcontextprotocol/server-sequential-thinking"]}')
        oc_json=$(echo "$oc_json" | jq \
            '.mcp["sequential-thinking"] = {"type":"local","command":["npx","-y","@modelcontextprotocol/server-sequential-thinking"],"enabled":true}')
    fi

    if cfg_is "mcps.tavily" "true"; then
        std_json=$(echo "$std_json" | jq \
            '.mcpServers.tavily = {"command":"npx","args":["-y","tavily-mcp@latest"],"env":{"TAVILY_API_KEY":"${TAVILY_API_KEY}"}}')
        oc_json=$(echo "$oc_json" | jq \
            '.mcp.tavily = {"type":"local","command":["npx","-y","tavily-mcp@latest"],"enabled":true,"environment":{"TAVILY_API_KEY":"${TAVILY_API_KEY}"}}')
    fi

    # Write files for each enabled agent
    if agent_enabled "claude"; then
        echo "$std_json" | jq . > "$project_dir/.mcp.json"
        log_ok ".mcp.json"
    fi

    if agent_enabled "cursor"; then
        ensure_dir "$project_dir/.cursor"
        echo "$std_json" | jq . > "$project_dir/.cursor/mcp.json"
        log_ok ".cursor/mcp.json"
    fi

    if agent_enabled "gemini"; then
        ensure_dir "$project_dir/.gemini"
        echo "$std_json" | jq . > "$project_dir/.gemini/settings.json"
        log_ok ".gemini/settings.json"
    fi

    if agent_enabled "opencode"; then
        echo "$oc_json" | jq . > "$project_dir/opencode.json"
        log_ok "opencode.json"
    fi
}
