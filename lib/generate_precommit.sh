#!/bin/bash
# Generates .pre-commit-config.yaml for the project.

generate_precommit() {
    local project_dir="$1"
    local template_dir="$2"

    if ! cfg_is version_control.pre_commit_hooks true; then
        log_info "Pre-commit hooks disabled, skipping"
        return
    fi

    log_step "Generating pre-commit config"

    local tmpl_file
    if [ "$PROJECT_TYPE" = "js" ]; then
        tmpl_file="$template_dir/precommit/pre-commit-config-js.yaml.tmpl"
    elif [ "$PROJECT_TYPE" = "py" ]; then
        tmpl_file="$template_dir/precommit/pre-commit-config-py.yaml.tmpl"
    fi

    if [ ! -f "$tmpl_file" ]; then
        log_warn "Pre-commit template not found: $tmpl_file"
        return
    fi

    # Pre-commit config needs conditional processing, not just var substitution
    local content
    content=$(<"$tmpl_file")
    content="$(process_conditionals "$content")"
    content="$(substitute_vars "$content")"
    echo "$content" > "$project_dir/.pre-commit-config.yaml"

    log_ok ".pre-commit-config.yaml"
}
