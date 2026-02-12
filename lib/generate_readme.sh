#!/bin/bash
# Generates project README.md from templates.

generate_readme() {
    local project_dir="$1"
    local template_dir="$2"

    log_step "Generating project README"

    local tmpl_file
    if [ "$PROJECT_TYPE" = "js" ]; then
        tmpl_file="$template_dir/project-readme/js.README.md.tmpl"
    elif [ "$PROJECT_TYPE" = "py" ]; then
        tmpl_file="$template_dir/project-readme/py.README.md.tmpl"
    fi

    if [ ! -f "$tmpl_file" ]; then
        log_warn "README template not found: $tmpl_file"
        return
    fi

    render_template "$tmpl_file" "$project_dir/README.md"
    log_ok "README.md"
}
