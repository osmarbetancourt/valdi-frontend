# Development Guide — Flutter Mercedes Analytics App

This document contains architecture guidance, conventions, recommended packages, and testing strategies for the Flutter mobile client.

Design goals
- Maintainable, testable architecture
- Clear separation of domain, data, and presentation
- Predictable state management and dependency injection
- Fast iteration while preserving production-grade quality

Recommended architecture (layered)
1. Presentation (UI)
   - Widgets, screens, theming, and navigation
   - Keep widgets small and do not perform heavy business logic here
2. Application / State
   - State holders (e.g., Riverpod providers or Bloc/Cubit classes)
   - Orchestrate use-cases, call services, and emit state changes
3. Domain (business models and use cases)
   - Immutable models (Freezed) and plain domain logic
4. Data / Infrastructure
   - API client(s), local persistence, caching, network interceptors
   - Error mapping and DTOs (Data Transfer Objects)

Suggested packages
- State & DI
  - riverpod (recommended) or flutter_bloc + bloc
  - get_it (service locator) — optional (riverpod often suffices)
- Networking
  - dio (HTTP client) + dio interceptors
  - retrofit (code-gen) or chopper (optional) for typed endpoints
  - pretty_dio_logger (dev)
- Models & code gen
  - freezed (immutable models & unions)
  - json_serializable / build_runner
- Persistence & caching
  - hive or sembast for lightweight offline cache
  - shared_preferences for small flags
- Auth & storage
  - flutter_secure_storage for tokens (only for non-cookie based secrets)
- UI & navigation
  - go_router or auto_route for navigation (or plain Navigator 2.0)
- Dev / quality
  - flutter_test, mocktail or mockito for mocking
  - lints: flutter_lints or custom analysis_options
  - dart format enforcement (pre-commit hooks)

Repository layout (example)
```
/lib
  /src
    /app.dart               # App entry & providers
    /main.dart
    /core                  # utilities, exceptions, logging
    /features
      /auth
        /data
        /domain
        /presentation
      /dashboard
      /conversations
      /payments
    /services             # API clients, storage adapters, analytics
    /models               # global model types (Freezed)
    /navigation
    /themes
/test
  unit, integration and widget tests
```

State management choices (short)
- Riverpod: concise, testable, composable. Works well for medium-large apps.
- Bloc: great for large teams who prefer strict event/state flows.

API client pattern
- Keep the HTTP client in /lib/src/services/api_client.dart
- Create typed service classes: `ConversationsApi`, `PaymentsApi`, `AuthApi` — these use Dio + interceptors
- Map JSON ↔ DTOs ↔ Domain models (Freezed) to keep domain clean
- Centralized error handling with typed exceptions

Authentication
- Backend uses JWT cookie auth in production. For cookies, prefer HTTP cookie handling using Dio cookie manager plugin or manually persist cookies into the app's cookie jar (if your backend sends HttpOnly cookies, a special strategy is required).
- Alternatively, if backend offers a token-based API for mobile, store tokens securely with flutter_secure_storage and send via Authorization header.
- Keep auth logic in `features/auth` and encapsulate session refreshing and cookie sync.

Testing strategy
- Unit tests with flutter_test and mocktail for services and providers
- Widget tests for reusable widgets and small screen flows
- Integration tests (flutter_driver or integration_test) for E2E flows
- CI: run `flutter test` and `flutter analyze`

Performance & best practices
- Use const constructors where possible
- Avoid unnecessary rebuilds — prefer const widgets and selectors (Riverpod `select`) or memoization
- Paginate large lists with infinite scroll and careful memory handling

CI & local dev
- Use FVM for controlled Flutter versions across the team
- Example commands:
  - `flutter format .`
  - `flutter analyze`
  - `flutter test`

Next steps
- Implement an initial Flutter scaffold with basic authentication and API client.
- Add CI pipeline to run tests and static analysis.

If you want, I can scaffold a minimal runnable Flutter app inside `/lib` now with a simple login flow and a sample API call to the existing backend. Which first feature would you like scaffolding for: Authentication or Dashboard?