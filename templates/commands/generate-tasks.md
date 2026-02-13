# Generating a Task List from a PRD

## Goal

Create a detailed, phased task list from a Product Requirements Document (PRD). Each task must be independently completable, clearly scoped, and easy to verify. The result guides a developer through implementation step by step.

## Output

- **Format:** Markdown (`.md`)
- **Location:** `/tasks/`
- **Filename:** `tasks-[prd-file-name].md`

## Process

1. **Receive PRD reference** — the user points to a PRD file in `/tasks/`.
2. **Analyze the PRD** — read functional requirements, user stories, acceptance criteria, and technical notes.
3. **Phase 1: Generate high-level phases** (~3–5 phases). Present phases to user without sub-tasks. Ask: *"I have outlined the phases. Ready to generate the full task breakdown? Reply 'Go' to proceed."*
4. **Wait for confirmation** — do not continue until the user says "Go".
5. **Phase 2: Generate full breakdown** — break each phase into small tasks (1–2 hours each). For every task include: Files, Estimate, Dependencies, and Verification.
6. **Add testing strategy** — list unit, integration, and manual test scenarios.
7. **Save** — write the output to `/tasks/tasks-[prd-file-name].md`.

## Task Sizing Rules

- **1–2 hours maximum** per task. If larger, break it down further.
- Each task must be completable in a single sitting.
- Each task must have a clear verification criterion — how do you know it's done?

## When to Use Multiple Phases

Use phases to group related work and make dependencies explicit:

| Pattern | Phase order |
|---------|------------|
| **Database-first** | Schema → Models → Business logic → API → Tests |
| **Feature-first** | Requirements → Interface → Core logic → Error handling → Tests → Docs |
| **Refactoring** | Add tests → Refactor incrementally → Verify green → Clean up → Update docs |

## Output Format

```markdown
# Task Breakdown: {Feature Name}

## Overview
{1–2 sentence description of what is being built and why}

## Relevant Files

| File | Purpose |
|------|---------|
| `src/auth/login.ts` | Login endpoint handler |
| `src/auth/login.test.ts` | Unit tests for login |
| `src/middleware/auth.ts` | JWT verification middleware |

## Prerequisites
- [ ] {Prerequisite 1 — e.g., database connection configured}
- [ ] {Prerequisite 2}

## Tasks

### Phase 1: {Phase Name}
**Goal:** {What this phase delivers}

- [ ] **Task 1.1:** {Clear, actionable description}
  - **Files:** `src/models/user.ts`, `migrations/001_users.sql`
  - **Estimate:** 1 hour
  - **Depends on:** none
  - **Verify:** Can create and retrieve a user from the database

- [ ] **Task 1.2:** {Description}
  - **Files:** `src/utils/password.ts`
  - **Estimate:** 30 min
  - **Depends on:** Task 1.1
  - **Verify:** Passwords hashed with bcrypt, not stored plain text

### Phase 2: {Phase Name}
**Goal:** {What this phase delivers}

- [ ] **Task 2.1:** {Description}
  - **Files:** `src/routes/auth.ts`, `src/controllers/auth.ts`
  - **Estimate:** 1.5 hours
  - **Depends on:** Phase 1 complete
  - **Verify:** POST /auth/login returns JWT on valid credentials

## Testing Strategy
- [ ] Unit tests: {what to unit test}
- [ ] Integration tests: {what flows to test end-to-end}
- [ ] Manual testing: {user scenarios to verify}

## Total Estimate
**Time:** {X} hours
**Complexity:** Low / Medium / High

## Notes
{Any important decisions, constraints, or context the implementer needs}
```

## Interaction Model

Always pause after Phase 1 (high-level phases) and wait for "Go" before expanding into detailed tasks. This prevents wasted work if the phases need adjustment.

## Target Audience

The primary reader is a **junior developer**. Requirements must be explicit, unambiguous, and immediately actionable.
