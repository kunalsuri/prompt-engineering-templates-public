# Prompt: Build a Modern FDD-Aware SaaS Starter Kit (Full-Stack, Port 5000)

## Role
You are an **expert full-stack engineer and software architect** with production experience in modern monorepos, feature-driven development (FDD), TypeScript, DevOps, and frontend/backend integration. Provide concise, deterministic outputs and include code comments. After generating artifacts, give a short numbered rationale (≤8 lines) explaining major design choices — do **not** reveal internal chain-of-thought.

## Environment constraints
- Target: Node >= 18, npm >= 8 (workspaces supported).
- Use npm workspaces (no pnpm).
- Use TypeScript `strict: true`.
- Deterministic sampling: `temperature=0.0`.

## Task
Generate a **monorepo** SaaS starter kit:
- Frontend: React + Vite + TypeScript, TailwindCSS with light/dark switcher.
- Backend: Node.js + Express + TypeScript, server listens on **port 5000**.
  - **Dev mode**: Express must integrate Vite dev server as middleware (vite.createServer with `middlewareMode: 'ssr'`) so the whole app is accessible at `http://localhost:5000`.
  - **Production**: Express serves the built frontend from `/client/dist` (or equivalent).
- Shared types & runtime validation: `packages/shared-types` using **Zod**; exports must be importable without type errors (provide tsconfig path mapping and build step).
- Authentication: `/api/v1/auth/signup` and `/api/v1/auth/login` using JSON file persistence **only for development**; JWT cookie-based auth (`HttpOnly`, `SameSite=Lax`, `secure` conditional on `NODE_ENV=production`). **Warn prominently** that JSON persistence is not production-ready.
- Error monitoring: integrate `@sentry/react` and a server-side Sentry init that reads `SENTRY_DSN` from env; if not provided, use a no-op sink.
- Logging: centralized logger at `/shared/utils/logger.ts` using Winston.
- Accessibility: semantic HTML, ARIA attributes, keyboard navigation support in examples.
- Styling: TailwindCSS; include a theme switcher component and example.
- Strict tooling: ESLint, Prettier, Husky, TypeScript strict mode, lint-staged.
- Testing: add unit tests (Vitest for frontend, Node test runner for backend) and run in CI.
- CI: Provide a GitHub Actions workflow (`.github/workflows/ci.yml`) that runs on `pull_request`, matrix test on Node LTS versions, and executes: install, lint, typecheck, build, test. Cache node modules.
- FDD enforcement: forbid deep imports into feature internals. Implement concrete enforcement:
  - Configure `eslint` with `no-restricted-imports` or `eslint-plugin-boundaries` and add a script `npm run check:feature-boundaries` that fails CI on violations.
  - Add `pre-merge` CI step to run `npm run check:feature-boundaries`.
- Scaffolder: provide `/scripts/new-feature.ts` (Node script) that scaffolds a feature folder with `components/`, `hooks/`, `api/`, `types.ts`, `index.ts` (re-export), and `README.md`. Script must be commented and idempotent.
- Seed script: `npm run seed` writes sample JSON files to `/data/*.json` for dev persistence.
- Export rules: enforce that each feature exposes public API **only** through its `index.ts` (add an ESLint rule and CI check).
- TODO markers: any ambiguous or missing production specs (e.g., DB choice, email provider, SENTRY_DSN, JWT secret rotation policy, hosting target) must be left as explicit `TODO` comments in code and README. Do **not** invent production secrets or providers.

## Acceptance criteria (implementable checks)
- `npm install` installs all workspace deps.
- `npm run dev` starts a single dev server on `http://localhost:5000` with hot reload.
- `npm run build` outputs client and server production artifacts.
- `npm run seed` populates `/data/*.json`.
- `npm run new-feature <name>` scaffolds the correct FDD structure and `index.ts` re-exports public API.
- Auth endpoints exist under `/api/v1/auth/*` with dev JSON persistence and JWT cookie auth; code includes an explicit warning comment about production readiness.
- `packages/shared-types` exports Zod schemas and TS types; imports succeed without type errors.
- CI workflow runs lint, type-check, build, and tests on PRs.
- Boundary checks fail the build if deep imports are detected.

## Deliverables (structured)
- A monorepo file tree (root + packages + client + server + scripts + data).
- Key code files in fenced blocks:
  - Root `package.json` (npm workspaces).
  - `/server/src/server.ts` with Vite dev middleware code path and production static serve.
  - `/client/src/main.tsx` and `/client/src/app.tsx`.
  - Example feature scaffold: `/features/user-management` with minimal functional code (components, API, types.ts, index.ts).
  - `/scripts/new-feature.ts` fully commented Node script.
- `README.md` with setup, dev, build, seed, new-feature usage, CI explanation, env var list (JWT_SECRET, SENTRY_DSN, COOKIE_SECURE, NODE_ENV), and the explicit production warning.
- Short numbered rationale (≤8 lines) summarizing the main architecture choices.

## Constraints & safety
- **Do not** output or invent real secrets (JWT secret, Sentry DSN). Use environment var placeholders.
- Remove any request for internal chain-of-thought. Replacement: short, transparent rationale only.
- Keep JSON persistence logic strictly gated to `NODE_ENV !== 'production'`.
- Add clear `TODO` comments for any missing production-level decisions.

## Execution note
- After generating files, run a self-check (lint + tsc + build + test + boundary check) and report pass/fail and any TODOs encountered in a concise list.

## Meta
- Use `temperature=0.0` for deterministic generation.
