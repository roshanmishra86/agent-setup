#!/bin/bash
# Generate CLI tools configurations (Justfile, .envrc, tmux, editorconfig)

generate_cli() {
    local project_dir="$1"
    local template_dir="$2"
    
    log_step "Generating CLI tools"

    # 1. Justfile
    if [ "$(cfg_get cli.tools.justfile false)" = "true" ]; then
        local src="$template_dir/cli/Justfile"
        local dst="$project_dir/Justfile"

        # Define commands based on project type
        if [ "$PROJECT_TYPE" = "js" ]; then
            TMPL_VARS[INSTALL_CMD]="bun install"
            TMPL_VARS[DEV_CMD]="bun run src/main.ts"
            TMPL_VARS[TEST_CMD]="bun test"
            TMPL_VARS[LINT_CMD]="bun x biome check ."
            TMPL_VARS[FORMAT_CMD]="bun x biome check --apply ."
        elif [ "$PROJECT_TYPE" = "py" ]; then
            local linter
            linter="$(cfg_get lint.py.linter ruff)"
            
            TMPL_VARS[INSTALL_CMD]="uv sync"
            TMPL_VARS[DEV_CMD]="uv run python -m src.main"
            TMPL_VARS[TEST_CMD]="uv run pytest"
            
            if [ "$linter" = "ruff" ]; then
                TMPL_VARS[LINT_CMD]="uv run ruff check ."
                TMPL_VARS[FORMAT_CMD]="uv run ruff format ."
            else
                TMPL_VARS[LINT_CMD]="uv run flake8 ."
                TMPL_VARS[FORMAT_CMD]="uv run black ."
            fi
        fi

        if render_template "$src" "$dst"; then
            log_ok "Justfile"
        fi
    fi

    # 2. .envrc (direnv)
    if [ "$(cfg_get cli.tools.direnv false)" = "true" ]; then
        local src="$template_dir/cli/envrc"
        local dst="$project_dir/.envrc"
        
        if [ -f "$src" ]; then
            cp "$src" "$dst"
            log_ok ".envrc"
            # Optional: warn about 'direnv allow'
            # log_info "Remember to run 'direnv allow'"
        fi
    fi

    # 3. tmux-session.sh
    if [ "$(cfg_get cli.tools.tmux false)" = "true" ]; then
        local src="$template_dir/cli/tmux-session.sh"
        local dst="$project_dir/start-dev.sh"
        
        if [ -f "$src" ]; then
            local content
            content=$(<"$src")
            content="${content//\{\{PROJECT_NAME\}\}/$PROJECT_NAME}"
            echo "$content" > "$dst"
            chmod +x "$dst"
            log_ok "start-dev.sh (tmux)"
        fi
    fi

    # 4. .editorconfig
    if [ "$(cfg_get cli.tools.editorconfig false)" = "true" ]; then
        local src="$template_dir/cli/editorconfig"
        local dst="$project_dir/.editorconfig"
        
        if [ -f "$src" ]; then
            cp "$src" "$dst"
            log_ok ".editorconfig"
        fi
    fi

    # 5. setup-dev-tools.sh
    if [ "$(cfg_get cli.tools.setup_script false)" = "true" ]; then
        local src="$template_dir/cli/setup-dev-tools.sh"
        local dst="$project_dir/scripts/setup-dev-tools.sh"
        
        ensure_dir "$project_dir/scripts"
        
        if [ -f "$src" ]; then
            cp "$src" "$dst"
            chmod +x "$dst"
            log_ok "scripts/setup-dev-tools.sh"
        fi
    fi
}
