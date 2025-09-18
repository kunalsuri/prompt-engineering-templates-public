---
mode: 'agent'
description: 'Design and implement a full observability system (logging, tracing, metrics) for React + TypeScript projects.'
---

Act as a Full Observability Architect.  
Your task is to design and integrate a **comprehensive observability system** providing robust logging, tracing, and metrics for a React + TypeScript SaaS application.

### ✅ Requirements

#### 1. Logging
- Use **structured logging** (JSON or key-value) for machine readability.
- Implement **log levels**: `debug`, `info`, `warn`, `error`, `fatal`.
- Centralize logging via a **logger utility/service**.
- Each log entry must include:
  - Timestamp (ISO format)
  - Log level
  - Component/module name
  - Contextual metadata (user ID, session, request ID, environment)
- Local dev logs go to **console**; production logs support adapters for Sentry, LogRocket, Datadog, OpenTelemetry.
- Avoid logging sensitive information (PII, tokens).

#### 2. Tracing
- Use **OpenTelemetry or similar** to instrument:
  - Component lifecycle events
  - API calls / service requests
  - Critical business logic paths
- Ensure traces include spans with metadata (duration, status, parent-child relationships).
- Provide a central **tracing utility** that can wrap functions, hooks, and async operations.

#### 3. Metrics
- Track **key performance indicators (KPIs)**:
  - Component render times
  - API request latency and success/failure counts
  - Error rates
- Expose metrics via a **metrics utility** that supports aggregation and optional reporting to external monitoring systems (Prometheus, Datadog).

#### 4. Error Handling Integration
- Integrate observability into **React error boundaries**.
- Capture uncaught exceptions and rejected promises.
- Enrich logs/traces with relevant metadata.

#### 5. Developer Guidelines
- Provide **hooks/utilities** for easy logging and tracing in components, hooks, and services.
- Ensure minimal performance overhead (lazy evaluation, batching, sampling where necessary).
- Include best practices checklist:
  - When to use which log level
  - Avoiding sensitive data
  - Adding trace spans for async operations
  - Consistent metrics naming and units

### 📦 Output
- `logger.ts` utility with pluggable transports and structured logs.
- `tracing.ts` utility for function/component instrumentation.
- `metrics.ts` utility for KPI tracking.
- Example usage in:
  - React components
  - Custom hooks
  - API services
- Integration guide for connecting with external observability/monitoring platforms.
- Summary checklist for developers to ensure consistent observability practices.
