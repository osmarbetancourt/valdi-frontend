# Valdi Android App Development Agent Prompt
```instructions
# Flutter Mobile App Development Agent Prompt

## Project Overview

You are tasked with developing a cross-platform Flutter mobile application that integrates with the existing Mercedes analytics backend API. The app will be a single codebase (Dart + Flutter) that supports both Android and iOS and provides a production-ready client for business analytics.

## Current State

- **Repository**: `valdi-frontend` — now repurposed as a Flutter mobile client starter repository (documentation-heavy; no active Valdi runtime code remains)
- **Documentation now present**:
  - `README.md` — top-level project summary and roadmap
  - `SETUP.md` — local Flutter dev environment, Android/iOS toolchain, emulators
  - `DEVELOPMENT.md` — architecture, state management, and patterns for the Flutter app
  - `API_INTEGRATION.md` — API integration guidelines and examples for Dart (Dio & cookie handling)
  - `MOBILE_SPECIFIC.md` — permissions, camera, biometrics, background work, plugin recommendations
  - `DEPLOYMENT.md` — release builds, signing, CI and store deployment guidance

- **Backend API**: Rust Axum server w/ PostgreSQL (JWT cookie auth, cursor pagination, business separation). The mobile client will interact with the same endpoints.

## Goals

1. Create a robust, cross-platform Flutter mobile app that integrates securely with the Mercedes analytics backend
2. Implement core features (authentication, dashboard, paginated conversations and payments, embedded analytics)
3. Provide native platform capabilities (camera, push notifications, biometrics, offline sync)
4. Deliver production-grade CI/CD, signing, tests, and monitoring
5. Maintain a clean, testable codebase with clear architecture and developer docs

## Technical Specifications

### Flutter & Dart
- **Language / Framework**: Dart (null-safety) + Flutter stable
- **Architecture**: Layered, testable architecture (presentation → application/state → domain → data)
- **State management**: Riverpod recommended; Bloc (optional) for teams that prefer event/state

### Mercedes Backend API (example)
```
Base URL: https://api-backoffice.mercedes-mb.org/api-docs/openapi.json
Auth: JWT tokens via cookies (server sets cookies; client may optionally support token-based fallback)
Endpoints of interest:
- POST /admin/login - login
- GET /conversations?cursor={}&limit={} - conversations
- GET /payments?cursor={}&limit={} - payments
- GET /metabase/embed/{dashboard_id} - embedded dashboards
- CRUD /admin/businesses - business management

See docs/API_REFERENCE.md for a short, mobile-focused summary of available endpoints and usage examples.
```

### Platform Requirements (guidelines)
- Android minSdkVersion: 21 (recommended for modern third-party libraries)
- Android target SDK: 34
- iOS minimum: 13.0+ (adjust based on customer support strategy)
- Permissions: camera, photos, microphone (if needed), location (if needed), notifications, biometrics

## Development Workflow

### Phase 1 — Project & Team Setup
1. Scaffold a canonical Flutter project and add it under `/app` or root (your preference)
2. Choose a version strategy (FVM recommended) and add `analysis_options.yaml`, linter, CI baseline
3. Create a lightweight module and integrate an example Auth flow to validate backend connectivity

### Phase 2 — Core Features (iterative)
1. Authentication: secure cookie-based session handling (Dio + dio_cookie_manager + PersistCookieJar) or token-based flow if the backend supports it
2. Dashboard: analytics overview, cards and navigation structure
3. Conversations: cursor-based pagination, infinite scroll, and detail screens
4. Payments: list, details, and filtering
5. Metabase embeds: WebView or server-provided embed URLs/tokens

### Phase 3 — Platform Integration
1. Camera / images: `image_picker` or `camera` for full capture features
2. Notifications: `firebase_messaging` + `flutter_local_notifications` for local and remote notifications
3. Biometrics: `local_auth` for device unlock/quick auth
4. Background sync: `workmanager` or platform-specific scheduling
5. Secure storage & cookie persistence: `flutter_secure_storage` for tokens and `cookie_jar` for cookies

### Phase 4 — Testing & Release
1. Unit tests and widget tests
2. Integration / E2E tests (integration_test)
3. CI: static analysis, unit tests, builds and artifact upload
4. Release builds: AAB for Android, IPA for iOS; manage signing keys outside of source control

## Code Standards & Best Practices

- Prefer small composable widgets and single-responsibility classes
- Use null-safety and strong typing across models (Freezed for immutable models)
- Keep business logic out of UI: use providers/services/repositories
- Use code generation (json_serializable / freezed / retrofit) to reduce boilerplate
- Follow release-safe feature branching and code reviews

## API Integration

- Use Dio with cookie management for session cookies (PersistCookieJar + CookieManager)
- Centralize an ApiClient with interceptors to handle logging, retry (when appropriate), and auth failures
- Map DTOs ↔ domain models via generated code; keep DTOs isolated in data layer
- Support cursor pagination with a PagedResult<T> wrapper and repository-level paging helpers

## Quality Assurance

- Define a test pyramid (heavy unit tests, fewer integration tests, selected E2E)
- Run `flutter analyze` and `flutter test` in CI; add format and lint checks
- Integrate Crashlytics or Sentry for crash reporting and observability

## Documentation & Files

- Keep these docs up to date: `README.md`, `SETUP.md`, `DEVELOPMENT.md`, `API_INTEGRATION.md`, `MOBILE_SPECIFIC.md`, `DEPLOYMENT.md`
- Project scaffold and initial tasks belong in `/app` or root; document project entrypoints and developer flows

## Next Actions Priority

1. Scaffold a minimal Flutter app and wire an Auth flow against the local backend (priority: validate connectivity)
2. Implement API client and basic paging for Conversations and Payments
3. Add CI pipeline and developer conveniences (FVM, pre-commit hooks)

Deliverables for the agent
- When asked to implement features, scaffold small, testable units with clear tests
- Add CI workflow templates for building Android (AAB) and iOS (IPA) and running tests
- Keep docs updated as features are added and break down work into small PR-friendly steps

If you want, I can now scaffold a minimal Flutter app with Auth and an ApiClient in `/app` (or `/mobile`) and add example CI — tell me which name and structure you prefer and I will create it.
``` 