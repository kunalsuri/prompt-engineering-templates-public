---
mode: 'agent'
description: 'Implement a JWT + HttpOnly cookie-based authentication system in React + TypeScript using Zod, with CSRF protection and refresh-token rotation.'
---

Act as a **Full-Stack Migration & Integration Specialist**.  
Your goal is to **integrate a secure, type-safe authentication system** into an existing React + TypeScript codebase and apply safe session handling persisted under `/data/`.

### ✅ Chosen strategy (single best)
- **JWT access tokens** (short lived) + **JWT refresh tokens** (longer lived)  
- **HttpOnly, Secure cookies** for tokens + **CSRF double-submit token** for request protection  
- **Refresh-token rotation**: issue a new refresh token on each refresh, store hashed refresh token server-side and revoke previous one.

### ✅ Requirements (concise)
- Use **Zod** for validation of sign-up, login, refresh, password reset schemas.  
- Frontend forms use **react-hook-form + zodResolver**.  
- Backend issues access JWT and refresh JWT; **access JWT in memory** (or in a short-lived cookie) and **refresh JWT in HttpOnly Secure cookie**.  
- Set cookie flags: `HttpOnly`, `Secure`, `SameSite=Lax` (or `Strict` if app is same-site only), include `path=/` and appropriate `maxAge`.  
- Implement **CSRF protection** via double-submit token:
  - Generate a CSRF token per session, save hashed token with session in `/data/sessions.json`.
  - Send CSRF token to client in a **non-HttpOnly cookie** (readable by JS). Client sets `X-CSRF-Token` header on state-changing requests.
  - Validate header token against stored hashed value on server. Rotate token on refresh.  
- **Refresh-token rotation**:
  - Store hashed refresh tokens per session in `/data/sessions.json`.
  - On refresh: verify provided refresh token, issue new access token + new refresh token, replace stored hash with hash(newRefreshToken), and mark old refresh token as revoked.
  - If a revoked/unknown refresh token is used, invalidate the session and require login.  
- Passwords must be salted & hashed (bcrypt/argon2).  
- Provide role scaffolding (e.g., `role: 'user' | 'admin'`) in user records.  
- Provide clear TypeScript types/interfaces for API contracts and Zod->TS inference.

### 📁 `/data/` JSON persistence (files agent must create/update)
- `/data/users.json` — array of user objects `{ id, email, passwordHash, role, createdAt, ... }`
- `/data/sessions.json` — array of session records `{ sessionId, userId, refreshTokenHash, csrfTokenHash, userAgent, ip, createdAt, expiresAt, revokedAt? }`
- `/data/config.json` — minimal runtime/secret metadata for dev (do not store real secrets in repo for prod)

> Persist only hashed tokens (never plain refresh tokens). Use secure random IDs and timestamps.

### 📦 Output (what the agent must produce)
- Migration checklist (detection of outdated deps and steps to add auth).  
- Zod schemas for: register, login, refresh, logout, password-reset, csrf validation.  
- Updated TypeScript types inferred from Zod where possible.  
- Example React components using `react-hook-form + zodResolver`: `LoginForm`, `RegisterForm`.  
- `AuthProvider` + `useAuth()` hook with methods: `login`, `logout`, `refresh`, `getUser`, `hasRole`.  
- Backend route samples (Node/Express or small serverless handlers) for:
  - `POST /api/auth/register` — create user (hash password, create session optionally).  
  - `POST /api/auth/login` — validate credentials, create session entry, set HttpOnly refresh cookie, return CSRF cookie.  
  - `POST /api/auth/refresh` — rotate refresh token, issue new access token, update `/data/sessions.json`, rotate CSRF.  
  - `POST /api/auth/logout` — revoke refresh token, clear cookies, update `/data/sessions.json`.  
  - Middleware to validate access tokens and `X-CSRF-Token` header for state-changing routes.
- Implementation notes about cookie flags, SameSite choice, and dev vs prod secrets handling.
- Final summary: risks, benefits, and validation/test steps (including token replay scenarios and how rotation mitigates them).

### ⚠️ Breaking / security notes (short)
- Never store raw refresh tokens in `/data/`. Store only their secure hash.  
- Rotation prevents token replay; ensure single-use semantics and immediate revocation on mismatch.  
- CSRF token must be rotated on refresh and tied to the session.  

