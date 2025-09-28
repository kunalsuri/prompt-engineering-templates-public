A full-stack monorepo template application built with React, TypeScript, and Express that serves as a foundation for future projects. Name it My-SAAS-APP. 
The app features a modern landing page with light/dark theme toggle, authentication flow (login/signup pages), and a dashboard accessible after login. 
All user and session data is stored as JSON files in a /data/ directory without requiring a database. 
The codebase follows a specific monorepo structure with /server/ and /client/ (feature modules like /client/src/features/user-profile/, shared components) to enable modular development and parallel team collaboration.

Core Features:


Build a modern, clean, and fully functional dashboard and user profile features that exactly match the layout and style in my Excalidraw image. 
Use the latest frontend frameworks (React, TypeScript, TailwindCSS, or similar) and follow best practices for maintainable, scalable code. 
The dashboard should be modular and ready for future feature additions. 
All user profile features should be implemented under client/src/features/user-profile/. 
Update users.json dynamically as required for user data management. 
Ensure responsive design, dark/light mode support, and state-of-the-art UI/UX patterns. 
Use clean folder structure, reusable components, and modern state management.

Landing page with light/dark theme toggle using React best practices
Authentication flow with login page, signup page, and protected dashboard accessible after login
JSON file-based storage in /data/ directory (users.json for user/session data), no database required
Monorepo structure with apps/ (web/, api/) and packages/ (user-profile/, shared components) for modular development
Visual References:
Inspired by GitHub landing pages, Vercel dashboards, and Excalidraw's clean interface, known for their professional, developer-focused design and smooth user experience.
Must use the components from https://ui.shadcn.com/ to design the sidebar, the dashboard, and other relevant state of the art ui. Keep them in seperate feature folders based on the best practices.

Style Guide:

Colors: Primary #0070F3 (blue), Secondary #7928CA (purple), Dark theme #000000, Light theme #FFFFFF, Text light #333333, Text dark #FFFFFF, Accent #FF0080
Design: Inter/SF Pro Display fonts, modern card-based UI with responsive grid system, 16px base spacing, Tailwind CSS for utility-first styling, Lucide icons for consistency, smooth theme transitions with proper contrast ratios
