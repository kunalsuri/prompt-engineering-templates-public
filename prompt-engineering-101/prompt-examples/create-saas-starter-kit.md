### **Goal: Build a Modern SaaS Starter Kit**
Create a full-stack SaaS application starter using React and TypeScript. The architecture must be feature-driven, clean, type-safe, and easy to extend, using JSON files for data storage during development. Do not hallucinate.
---
### **Core Requirements**
*   **Monorepo Structure:** A single repository containing separate folders for `client`, `server`, and `packages` (for shared code).
*   **Feature-Driven Architecture:** Both client and server code should be organized by feature (e.g., `features/user-management`).
*   **JSON File Storage:** All application data (like users) must be stored in `.json` files within a `/data` directory. **This method is strictly for development and prototyping.**
*   **Strong Type Safety:** Use **Zod** to define data schemas that are shared between the client and server to prevent errors.
*   **Excellent Developer Experience:** Include tools like code formatters, linters, and a feature generator script to speed up development.
*   **Imports:** Always import from index.ts boundaries, not deep paths. Example: import { useUser, UserProfile } from "@/features/user-management";
*   **Documentation:** Each `/features/[feature]` folder must include `README.md` explaining: Purpose, Public API exposed in `index.ts`, Dependencies
*   **Automation Rules:** When generating new features, enforce the following: Location: `/features/[feature-name]`. Subfolders: `components/`, `hooks/`, `api/`, `types.ts`, `index.ts`. Public API exported from `index.ts` only
---
### **Tech Stack**
*   **Frontend (`/client`):** React, Vite, TypeScript, TailwindCSS
*   **Backend (`/server`):** Node.js, Express, TypeScript
*   **State Management:** React Query (for server data) & Zustand (for UI state)
*   **Routing:** React Router
*   **Shared Code (`/packages`):** Zod (for schemas), TypeScript
---
### **Project Structure**
```
/repo
  /client
    /src
      /features
        /user-management
          components/
          hooks/
          api/
          types.ts
          index.ts
          README.md
      /components    # global UI (Navbar, Layout, ErrorBoundary)
      /shared        # hooks, utils, apiClient, logger
      main.tsx / app.tsx
  /server
    /src
      /features      # mirrors client for parity
        /user-management
          routes/
          services/
          types.ts
          index.ts
          README.md
      /middlewares
      /utils
      server.ts
  /packages
    /shared-types
    /shared-utils
  /data
    users.json
    settings.json
  /config
    envs/
      dev.ts
      prod.ts
  /scripts
    new-feature.ts   # scaffolder
  README.md
```
---
### **Detailed Specifications**
#### **1. Data & Persistence**
*   All application data must be stored in `.json` files inside the `/data` directory (e.g., `/data/users.json`).
*   The server's API will read from and write directly to these JSON files. There will be **no database**.
*   A "seed" script must be created to populate the JSON files with initial sample data.
*   The documentation must clearly state that this JSON storage system is not suitable for production.
---
#### **2. API & Security**
*   Create a versioned REST API (e.g., `/api/v1/...`) with consistent error envelopes { status, code, message, details? }
*   Use Zod schemas to validate all incoming API requests.
*   Implement secure user authentication (signup/login) using JWTs stored in cookies.
*   Hash all user passwords with **bcrypt** before storing them in `users.json`. default user = admin, password = admin123
*   Rate limit and brute-force protection on auth endpoints
---
#### **3. Developer Experience & Automation**
*   **Strict Tooling:** Enforce code quality with ESLint, Prettier, and TypeScript's strict mode.
*   **Pre-commit Hooks:** Use Husky to automatically lint and format code before every commit.
*   **CI Pipeline:** Set up a GitHub Actions workflow to run checks (linting, type-checking, build) on every pull request.
*   **Feature Scaffolder:** Create a script (`/scripts/new-feature.ts`) that automatically generates the necessary folders and boilerplate files for a new feature.
---
#### **4. User Interface (`/client`)**
*   Build a simple landing page, login/signup pages, and a protected dashboard.
*   Use **TailwindCSS** for styling and implement a light/dark mode theme switcher.
*   Use **React Hook Form** with the Zod resolver for type-safe forms.
---
#### **5. Logging & Error Management**
*   Create /shared/utils/logger.ts wrapping winston
*   Add ErrorBoundary.tsx in /components to catch runtime errors gracefully
*   integrate @sentry/react for monitoring
---
#### **6. Theming (Dark/Light Mode)**
*   Sidebar background: #121212 (darker)
*   Dashboard background: #1e1e1e (slightly lighter)
*   Define colors in Tailwind config, not in components
*   Guarantee accessible contrast ratios
*   Maintain full dark/light mode compatibility
---
### **Final Deliverables**
1.	A complete Git repository with the specified monorepo structure.
2.	A working React frontend modern landing page with authentication and a user dashboard.
3.	A working Node.js backend that uses `/data/users.json` for user storage. Dev JSON persistence with seed and migration scripts
4.	Shared Zod schemas for type safety across the entire application
5.	Logger utilities, ErrorBoundary, Tailwind theme config
6.	Accessibility: semantic HTML, ARIA attributes, keyboard navigation
7.	A CI pipeline configuration and the feature scaffolder script.
8.	A `README.md` file explaining how to set up and run the project.
