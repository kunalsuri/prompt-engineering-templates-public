# General + React + TypeScript Ruleset

## Meta Rule
- Ensure full compliance with recent industry best practices.
- Follow **Feature-Driven Modular Architecture** in React.
- Audit, refactor, and fix existing errors or issues before adding new code.
- Be concise and precise; avoid speculative or context-less code (no hallucinations).
- Prioritize readability, simplicity, and maintainability.
- Always implement code as **modular, reusable components**.
- Rules apply exclusively to **React + TypeScript (web) projects**.

## Code Style
- Use **functional components** with React hooks; classes are disallowed.
- No side effects or async logic inside render methods.
- Avoid code duplication; extract shared logic into hooks or utilities.
- Keep components small and single-responsibility.

## Naming
- Directories: `lowercase-dash` style (e.g., `components/auth-wizard`).
- Variables: descriptive, use auxiliary verbs (`isLoading`, `hasError`).
- Custom hooks: prefixed with `use` (e.g., `useFetch`).
- Use named exports; reserve default export only for main components.

## TypeScript
- Enable **strict mode** including strict null checks.
- Prefer `interface` over `type` for object contracts.
- Avoid `any`; only allowed with explicit comments justifying its use.
- Avoid `enum` unless string enums are explicitly needed.

## Syntax
- Use `function` keyword for pure functions.
- Prefer arrow functions for callbacks unless `function` is required (e.g., dynamic `this`).
- Always use braces `{}` for conditionals and blocks, even for single statements.
- JSX must remain declarative.

## Formatting & Linting
- Enforce **Prettier** for formatting.
- Use **ESLint** with recommended React + TypeScript rules.
- Ensure code passes linting before completion.

## Styling
- Use **Tailwind CSS** or **styled-components**.
- Layouts must be responsive (Flexbox, Grid, or container queries).
- Support dark mode with CSS variables or `next-themes`.
- For Tailwind: respect configuration files.
- For styled-components: use consistent naming, avoid inline styles.

## Accessibility
- Use **semantic HTML** elements.
- Apply ARIA roles only where appropriate.
- Verify keyboard navigation support and focus management.
- Test accessibility with **Lighthouse** or **axe**.

## Animations
- Use **Framer Motion** or **React Spring**.
- Keep animations minimal to avoid performance issues.

## Error Handling
- Handle all async operations with proper `try/catch` or error boundaries.
- Display user-friendly error states (e.g., fallback UI, toast notifications).

## Testing
- Write unit tests for components (Jest + React Testing Library).
- Ensure new features include coverage for critical paths.

## Output Expectations (for AI agent)
- Provide complete code blocks per file, prefixed with filename (e.g., `// src/components/Button.tsx`).
- Include comments for complex logic.
- After code, provide a short **checklist of integration steps**.
