# Generating a Product Requirements Document (PRD)

## Goal

Create a detailed Product Requirements Document (PRD) in Markdown format, based on an initial user prompt. The PRD should be clear, actionable, and suitable for a junior developer to understand and implement the feature.

## Process

1. **Receive Initial Prompt:** The user provides a brief description or request for a new feature or functionality.
2. **Ask Clarifying Questions:** Before writing the PRD, ask clarifying questions to gather sufficient detail. The goal is to understand the "what" and "why" of the feature, not necessarily the "how." Provide options in letter/number lists so the user can respond easily with selections.
3. **Generate PRD:** Based on the initial prompt and the user's answers, generate a PRD using the structure outlined below.
4. **Save PRD:** Save the generated document as `prd-[feature-name].md` inside the `/tasks/` directory.

## Clarifying Questions (Examples)

Adapt questions based on the prompt. Common areas to explore:

- **Problem/Goal:** "What problem does this feature solve for the user?" or "What is the main goal?"
- **Target User:** "Who is the primary user of this feature?"
- **Core Functionality:** "What key actions should a user be able to perform?"
- **User Stories:** "Could you provide a few user stories? (e.g., As a [type of user], I want to [action] so that [benefit].)"
- **Acceptance Criteria:** "How will we know when this feature is successfully implemented?"
- **Scope/Boundaries:** "Are there specific things this feature should NOT do (non-goals)?"
- **Data Requirements:** "What data does this feature need to display or manipulate?"
- **Design/UI:** "Are there existing design mockups or UI guidelines to follow?"
- **Edge Cases:** "Are there potential edge cases or error conditions to consider?"

## PRD Structure

1. **Introduction/Overview:** Briefly describe the feature and the problem it solves.
2. **Goals:** List specific, measurable objectives.
3. **User Stories:** Detail user narratives describing feature usage and benefits.
4. **Functional Requirements:** List specific functionalities (numbered).
5. **Non-Goals (Out of Scope):** Clearly state what this feature will NOT include.
6. **Design Considerations (Optional):** Link to mockups, describe UI/UX requirements.
7. **Technical Considerations (Optional):** Mention known constraints, dependencies, or suggestions.
8. **Success Metrics:** How will success be measured?
9. **Open Questions:** List remaining questions or areas needing clarification.

## Target Audience

The primary reader is a **junior developer**. Requirements should be explicit, unambiguous, and avoid jargon where possible.

## Output

- **Format:** Markdown (`.md`)
- **Location:** `/tasks/`
- **Filename:** `prd-[feature-name].md`

## Final Instructions

1. Do NOT start implementing the PRD.
2. Ask the user clarifying questions first.
3. Incorporate the user's answers to improve the PRD.
