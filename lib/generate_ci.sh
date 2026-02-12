#!/bin/bash
# Generates GitHub Actions CI workflow for the project.

generate_ci() {
    local project_dir="$1"
    local template_dir="$2"

    if ! cfg_is ci.enabled true; then
        log_info "CI generation disabled, skipping"
        return
    fi

    log_step "Generating CI workflow"

    local ci_dir="$project_dir/.github/workflows"
    ensure_dir "$ci_dir"

    local tmpl_file
    if [ "$PROJECT_TYPE" = "js" ]; then
        tmpl_file="$template_dir/ci/github-actions-js.yml.tmpl"
    elif [ "$PROJECT_TYPE" = "py" ]; then
        tmpl_file="$template_dir/ci/github-actions-py.yml.tmpl"
    fi

    if [ ! -f "$tmpl_file" ]; then
        log_warn "CI template not found: $tmpl_file"
        return
    fi

    render_template "$tmpl_file" "$ci_dir/ci.yml"
    log_ok ".github/workflows/ci.yml"
}
