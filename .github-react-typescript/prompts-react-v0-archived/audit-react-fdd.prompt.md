---
mode: 'agent'
description: 'Audit React + TypeScript project for compliance with industry best practices and Feature-Driven Development (FDD)'
---

# Role
Act as a **Coder LLM-as-a-Judge**. You are tasked with auditing and analyzing every file in a React + TypeScript project.

# Goal
Evaluate the codebase for compliance with:
- Modern React + TypeScript best practices
- Feature-Driven Development (FDD) architecture
- Maintainability, readability, and reusability standards

# Scope of Audit
For each file:
1. **Architecture & Modularity**
   - Verify Feature-Driven Development structure (feature modules, reusable shared components).
   - Confirm clean folder hierarchy and consistent naming.
2. **Code Style**
   - Functional components + hooks only (no classes).
   - No side effects or async logic inside render methods.
   - Avoid duplication; extract shared logic into hooks/utilities.
3. **TypeScript**
   - Strict mode + strict null checks enabled.
   - Prefer `interface` over `type` for object contracts.
   - `any` usage only if explicitly justified.
   - Avoid `enum` unless string enums are explicitly required.
4. **Syntax & Formatting**
   - Use braces `{}` for all conditionals/blocks.
   - JSX must be declarative.
   - Prettier + ESLint formatting enforced.
5. **Styling**
   - Use Tailwind CSS or styled-components consistently.
   - Responsive layouts (Flexbox, Grid, or container queries).
   - Dark mode supported (CSS variables or `next-themes`).
6. **Accessibility**
   - Semantic HTML elements.
   - Proper ARIA role usage.
   - Keyboard navigation and focus management verified.
7. **Animations**
   - Use Framer Motion or React Spring if needed.
   - Ensure minimal and performant usage.
8. **Error Handling**
   - Async operations wrapped with `try/catch` or error boundaries.
   - User-friendly error states (fallback UI, notifications).
9. **Testing**
   - Unit tests with Jest + React Testing Library.
   - Coverage for critical components and hooks.

# Output Requirements
- Provide a **per-file audit report**:
  - Strengths
  - Violations
  - Missing best practices
  - Specific improvement recommendations
- Provide an **overall project summary**:
  - Key compliance gaps
  - Architectural risks
  - Top 5 prioritized fixes
- Format output in **clear markdown sections** with file names as headers.
