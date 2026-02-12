#!/bin/bash
# Derives agent-specific config files from AGENTS.md content.

generate_agent_configs() {
    local project_dir="$1"
    local template_dir="$2"
    local agents_tmpl_dir="$template_dir/agents"

    local agents_content
    agents_content=$(<"$project_dir/AGENTS.md")

    # Set up template vars for agent wrappers
    local type_label
    [ "$PROJECT_TYPE" = "js" ] && type_label="JavaScript / TypeScript (Bun)"
    [ "$PROJECT_TYPE" = "py" ] && type_label="Python (uv)"
    TMPL_VARS[PROJECT_TYPE_LABEL]="$type_label"

    log_step "Generating agent configs"

    # --- CLAUDE.md ---
    if agent_enabled "claude"; then
        render_template "$agents_tmpl_dir/CLAUDE.md.tmpl" "$project_dir/CLAUDE.md"
        log_ok "CLAUDE.md"
    fi

    # --- GEMINI.md ---
    if agent_enabled "gemini"; then
        render_template "$agents_tmpl_dir/GEMINI.md.tmpl" "$project_dir/GEMINI.md"
        log_ok "GEMINI.md"
    fi

    # --- GitHub Copilot ---
    if agent_enabled "copilot"; then
        ensure_dir "$project_dir/.github"
        render_template "$agents_tmpl_dir/copilot-instructions.md.tmpl" "$project_dir/.github/copilot-instructions.md"
        log_ok ".github/copilot-instructions.md"
    fi

    # --- Windsurf ---
    if agent_enabled "windsurf"; then
        render_template "$agents_tmpl_dir/windsurfrules.tmpl" "$project_dir/.windsurfrules"
        log_ok ".windsurfrules"
    fi

    # --- Aider ---
    if agent_enabled "aider"; then
        # CONVENTIONS.md = copy of AGENTS.md content (aider reads this)
        cp "$project_dir/AGENTS.md" "$project_dir/CONVENTIONS.md"
        render_template "$agents_tmpl_dir/aider.conf.yml.tmpl" "$project_dir/.aider.conf.yml"
        log_ok "CONVENTIONS.md + .aider.conf.yml"
    fi

    # --- Cursor (.cursor/rules/*.mdc) ---
    if agent_enabled "cursor"; then
        generate_cursor_rules "$project_dir" "$template_dir"
        log_ok ".cursor/rules/"
    fi

    # --- Cline (.clinerules/*.md) ---
    if agent_enabled "cline"; then
        generate_cline_rules "$project_dir" "$template_dir"
        log_ok ".clinerules/"
    fi

    # --- Amazon Q (.amazonq/rules/*.md) ---
    if agent_enabled "amazonq"; then
        generate_amazonq_rules "$project_dir" "$template_dir"
        log_ok ".amazonq/rules/"
    fi
}

# --- Cursor: split rules into .mdc files with YAML frontmatter ---
generate_cursor_rules() {
    local project_dir="$1"
    local template_dir="$2"
    local rules_dir="$template_dir/rules"
    local out_dir="$project_dir/.cursor/rules"
    ensure_dir "$out_dir"

    # Map rule files to cursor-specific metadata
    write_cursor_rule "$rules_dir/coding-style.md" "$out_dir/coding-style.mdc" \
        "Code style, naming, and design guidelines" "**" "true"

    write_cursor_rule "$rules_dir/testing.md" "$out_dir/testing.mdc" \
        "Testing philosophy and requirements" "**/*.test.*,**/*.spec.*,**/tests/**" "true"

    write_cursor_rule "$rules_dir/version-control.md" "$out_dir/version-control.mdc" \
        "Version control and commit conventions" "**" "true"

    if [ "$PROJECT_TYPE" = "js" ]; then
        write_cursor_rule "$rules_dir/tooling-js.md" "$out_dir/tooling.mdc" \
            "JavaScript/TypeScript tooling and commands" "**/*.ts,**/*.js,**/*.tsx,**/*.jsx" "true"
    elif [ "$PROJECT_TYPE" = "py" ]; then
        write_cursor_rule "$rules_dir/tooling-py.md" "$out_dir/tooling.mdc" \
            "Python tooling and commands" "**/*.py" "true"
    fi
}

write_cursor_rule() {
    local src="$1" dst="$2" description="$3" globs="$4" always_apply="$5"

    if [ ! -f "$src" ]; then return; fi

    local content
    content=$(<"$src")
    content="$(process_conditionals "$content")"
    content="$(substitute_vars "$content")"

    {
        echo "---"
        echo "description: \"$description\""
        echo "globs: \"$globs\""
        echo "alwaysApply: $always_apply"
        echo "---"
        echo ""
        echo "$content"
    } > "$dst"
}

# --- Cline: split rules into plain .md files ---
generate_cline_rules() {
    local project_dir="$1"
    local template_dir="$2"
    local rules_dir="$template_dir/rules"
    local out_dir="$project_dir/.clinerules"
    ensure_dir "$out_dir"

    write_processed_rule "$rules_dir/coding-style.md" "$out_dir/coding-style.md"
    write_processed_rule "$rules_dir/testing.md" "$out_dir/testing.md"
    write_processed_rule "$rules_dir/version-control.md" "$out_dir/version-control.md"

    if [ "$PROJECT_TYPE" = "js" ]; then
        write_processed_rule "$rules_dir/tooling-js.md" "$out_dir/tooling.md"
    elif [ "$PROJECT_TYPE" = "py" ]; then
        write_processed_rule "$rules_dir/tooling-py.md" "$out_dir/tooling.md"
    fi
}

# --- Amazon Q: split rules into plain .md files ---
generate_amazonq_rules() {
    local project_dir="$1"
    local template_dir="$2"
    local rules_dir="$template_dir/rules"
    local out_dir="$project_dir/.amazonq/rules"
    ensure_dir "$out_dir"

    write_processed_rule "$rules_dir/coding-style.md" "$out_dir/coding-style.md"
    write_processed_rule "$rules_dir/testing.md" "$out_dir/testing.md"
    write_processed_rule "$rules_dir/version-control.md" "$out_dir/version-control.md"

    if [ "$PROJECT_TYPE" = "js" ]; then
        write_processed_rule "$rules_dir/tooling-js.md" "$out_dir/tooling.md"
    elif [ "$PROJECT_TYPE" = "py" ]; then
        write_processed_rule "$rules_dir/tooling-py.md" "$out_dir/tooling.md"
    fi
}

# Helper: process a rule file (conditionals + vars) and write to destination
write_processed_rule() {
    local src="$1" dst="$2"
    if [ ! -f "$src" ]; then return; fi

    local content
    content=$(<"$src")
    content="$(process_conditionals "$content")"
    content="$(substitute_vars "$content")"
    echo "$content" > "$dst"
}
