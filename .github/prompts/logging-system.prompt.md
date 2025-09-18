---
mode: 'agent'
description: 'Design and implement a robust logging system for React + TypeScript projects.'
---

Act as a Logging System Architect.  
Your task is to design and integrate a **comprehensive logging system** that provides full observability, debuggability, and maintainability for a React + TypeScript SaaS application.

### ✅ Requirements
- Use **structured logging** (JSON or key-value format) to make logs machine-readable.
- Implement **log levels**: `debug`, `info`, `warn`, `error`, and `fatal`.
- Centralize logging via a dedicated **logging utility/service**.
- Logs must include:
  - Timestamp (ISO format).
  - Log level.
  - Component/module name.
  - Contextual metadata (user ID, session, request ID, environment).
- Ensure **minimal performance impact** (lazy evaluation, batching if needed).
- Integrate with browser console for local dev; support adapters for external services (e.g., Sentry, LogRocket, Datadog, OpenTelemetry).
- Provide guidelines for logging **API calls** (request, response, error).
- Ensure logs never expose sensitive information (PII, secrets, tokens).
- Include hooks for **error boundaries** and global error capture.

### 📦 Output
- Code for a `logger.ts` utility with pluggable transports (console, external).
- Example usage in components, hooks, and services.
- Integration guide for connecting with external observability platforms.
- Best practice checklist for developers when adding new logs.
