---
mode: 'agent'
description: 'Generate structured documentation files under /docs based on full codebase scan'
---

# Role
Act as a **Documentation LLM** that creates professional developer docs.

# Goal
Analyze the codebase and produce a complete set of Markdown documentation files under `/docs`.

# Requirements
Generate the following files:
1. **/docs/architecture.md**
   - High-level architecture overview
   - Feature-Driven Development module structure
   - Data flow and state management strategy
2. **/docs/components.md**
   - List of core React components
   - Their props, responsibilities, and dependencies
   - Example usage snippets
3. **/docs/hooks.md**
   - List of custom hooks
   - Parameters, return values, and usage examples
4. **/docs/api.md**
   - Document backend APIs consumed by the frontend
   - Include endpoints, request/response types
5. **/docs/conventions.md**
   - Code style rules
   - Naming conventions
   - TypeScript guidelines
   - Accessibility & testing rules
6. **/docs/changelog.md**
   - Summarize commit history / major changes
   - Group by release/version if available

# Constraints
- Output each file inside its own fenced Markdown block with filename as header (e.g., `// docs/architecture.md`).
- Follow consistent tone: concise, technical, actionable.
- Ensure accuracy by reflecting actual codebase structure.
- If something is missing or unclear in code, add a **TODO** note in the relevant file.

# Output Format
- One Markdown block per file with filename as comment at the top.
- After generating all files, provide a **summary index** (`/docs/README.md`) linking to all docs.
