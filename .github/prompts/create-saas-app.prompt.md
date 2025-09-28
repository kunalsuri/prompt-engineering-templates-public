
---
mode: 'agent'
description: 'Build My-SAAS-APP – A Full-Stack Monorepo Template with React, TypeScript & Express'
---

# Role
Act as a **Coding LLM** with the role of an **expert full-stack engineer** tasked with creating a **feature-based monorepo template application** named **My-SAAS-APP**.  

The system should be modern, modular, and serve as a foundation for future SaaS projects.

---

## Core Setup
- **Stack**: React (TypeScript) + Express (TypeScript)  
- **Styling/UI**: TailwindCSS + [shadcn/ui](https://ui.shadcn.com/) + Lucide Icons  
- **Fonts**: Inter / SF Pro Display  
- **Design Language**: Card-based UI, responsive grid, 16px base spacing, smooth theme transitions  

---

## Monorepo Structure
My-SAAS-APP/
├── client/                          # React + TypeScript frontend
│   └── src/
│       ├── features/                # Feature-based structure
│       │   └── user-profile/        # User profile module
│       │       ├── components/      # Feature-specific components
│       │       ├── hooks/           # Feature-specific hooks
│       │       └── index.ts         # Entry for feature
│       ├── components/              # Shared UI components
│       │   ├── Button.tsx
│       │   ├── Card.tsx
│       │   └── ThemeToggle.tsx
│       ├── pages/                   # Page-level routes
│       │   ├── Landing.tsx
│       │   ├── Login.tsx
│       │   ├── Signup.tsx
│       │   └── Dashboard.tsx
│       ├── lib/                     # Client utilities
│       │   ├── api.ts               # API calls (fetch wrappers)
│       │   └── state.ts             # Zustand/React Query setup
│       ├── App.tsx                  # Main app component
│       └── main.tsx                 # React entrypoint
│
├── server/                          # Express + TypeScript backend
│   ├── routes/                      # Route definitions
│   │   ├── auth.ts
│   │   ├── users.ts
│   │   └── sessions.ts
│   ├── controllers/                 # Route handlers/business logic
│   │   ├── authController.ts
│   │   └── userController.ts
│   ├── middleware/                  # Middleware functions
│   │   └── authMiddleware.ts
│   ├── utils/                       # Helpers
│   │   ├── fileStorage.ts           # Read/write JSON helpers
│   │   └── validation.ts
│   └── server.ts                    # Express server entrypoint
│
├── data/                            # File-based storage (prototype only)
│   └── users.json                   # User + session storage
│
├── package.json
├── tsconfig.json
└── README.md


- Use **feature-based folders** under `/client/src/features/*` for modular development.  
- Example: `/client/src/features/user-profile/` should handle all profile logic.  
- Ensure modularity so frontend and backend teams can work in parallel.

---

## Features

### Landing Page
- Inspired by GitHub & Vercel landing pages.  
- Clean, professional design.  
- Light/dark theme toggle using React best practices.

### Authentication
- Login & signup pages.  
- Protected dashboard only accessible after login.  
- Store **users and session data** in `/data/users.json`.  
- Update JSON dynamically for CRUD operations.  

### Dashboard
- Must replicate the **layout & style from GitHub**.  
- Sidebar, dashboard, and other UI elements must use **shadcn/ui** components.  
- Modular and future-ready (feature-based).  
- Dark/light theme supported out of the box.  

### User Profile
- Implemented under `/client/src/features/user-profile/`.  
- Supports editing and saving profile details.  
- Data synced with `users.json`.  

---

## Style Guide
- **Colors**
  - Primary: `#0070F3` (blue)  
  - Secondary: `#7928CA` (purple)  
  - Accent: `#FF0080`  
  - Dark: `#000000`  
  - Light: `#FFFFFF`  
  - Text (light): `#333333`  
  - Text (dark): `#FFFFFF`  

- **UI/UX Patterns**
  - Responsive design (desktop + mobile).  
  - Smooth transitions (dark/light mode).  
  - Reusable cards, buttons, inputs from `shadcn/ui`.  
  - State management: modern (React Query/Zustand/Context depending on feature scope).  

---

## Visual References
- GitHub landing pages (clean, developer-focused).  
- Vercel dashboards (professional, minimal).  
- Excalidraw (lightweight, intuitive interface).  

---

**Goal**: Deliver a **production-grade, scalable monorepo** with modular feature folders, JSON-based storage, authentication, and a visually polished dashboard + landing page, fully aligned with the style guide.  
