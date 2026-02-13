# Git Worktree Management

Manage git worktrees to enable parallel development on multiple branches without switching contexts.

**Usage:** `/worktrees [create|list|cleanup|prs|<branch-name>]`

## Operations

### `list` — Show active worktrees
```
git worktree list
```
Report status of each worktree and flag any stale or problematic ones.

### `prs` — Create worktrees for all open PRs
1. Run `gh pr list --json headRefName,title,number` to get open PRs
2. For each PR branch, create: `git worktree add ./tree/<branch-name> <branch-name>`
3. Handle branch names with slashes by creating nested directories
4. Report which worktrees were created, skipped (already exist), or failed

### `<branch-name>` — Create worktree for specific branch
1. Check if branch exists locally or remotely
2. Create: `git worktree add ./tree/<branch-name> <branch-name>`
3. If branch doesn't exist, offer to create it: `git worktree add -b <branch-name> ./tree/<branch-name>`

### `new <branch-name>` — Create new branch + worktree
1. Prompt for base branch (default: main/master)
2. Create branch and worktree simultaneously
3. Set up tracking if needed

### `cleanup` — Remove stale worktrees
1. Identify branches that no longer exist locally or remotely
2. Remove corresponding worktrees: `git worktree remove ./tree/<branch-name>`
3. Clean up empty directories in `./tree/`
4. Run `git worktree prune`

## Directory Structure

Worktrees are organized under `./tree/` in the repo root:

```
project/
├── src/                    ← main repo files
└── tree/
    ├── feature-auth/       ← worktree for feature/auth branch
    ├── bugfix-login/       ← worktree for bugfix/login branch
    └── chore-deps/         ← worktree for chore/update-deps branch
```

## Report Format

```
## Worktree Status

**Operation:** [what was done]

### Active Worktrees
/path/to/repo              [main]           (primary)
/path/to/repo/tree/feat    [feature/auth]   (worktree)
/path/to/repo/tree/fix     [bugfix/login]   (worktree)

### Actions
- Created: [N worktrees]
- Skipped: [N already existed]
- Removed: [N stale worktrees]

### Issues
[any errors, missing branches, or auth issues]

### Next Steps
- Work on a branch: cd tree/<branch-name>
- Merge when done, then run: /worktrees cleanup
```

## Requirements
- `gh` CLI must be installed and authenticated for PR operations
- Worktrees require that branches exist or are created explicitly
