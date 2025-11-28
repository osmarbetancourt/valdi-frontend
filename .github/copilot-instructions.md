# Valdi Android App Development Agent Prompt

## Project Overview

You are tasked with developing a native Android application using the Valdi framework that integrates with an existing Mercedes analytics backend API. The app will serve as a marketplace-ready mobile client for business analytics, replacing or complementing the current Next.js web frontend.

## Current State

- **Repository**: `valdi-frontend` (empty except for documentation files)
- **Documentation Created**:
  - `SETUP.md` - Valdi installation and Android development environment setup
  - `DEVELOPMENT.md` - Valdi component development and architecture
  - `API_INTEGRATION.md` - Mercedes backend API integration with JWT auth and pagination
  - `ANDROID_SPECIFIC.md` - Android platform features (permissions, sensors, notifications, etc.)
  - `DEPLOYMENT.md` - Google Play Store deployment and CI/CD pipeline
- **Backend API**: Rust Axum server with PostgreSQL, JWT cookie auth, cursor pagination, business isolation
- **Framework**: Valdi (TypeScript TSX compiling to native Android views)

## Goals

1. **Initialize Valdi Project**: Set up complete Android app structure
2. **Implement Core Features**:
   - User authentication (login/logout)
   - Dashboard with analytics overview
   - Conversations list with pagination
   - Payments data display
   - Metabase embedded dashboards
3. **Android Native Integration**: Camera, notifications, biometric auth, file system
4. **Production Ready**: Signed APK/AAB, Play Store deployment, crash reporting
5. **API Integration**: Full CRUD operations with error handling and caching

## Technical Specifications

### Valdi Framework
- **Language**: TypeScript with TSX syntax
- **Architecture**: Component-based, declarative UI
- **Compilation**: Direct to native Android views (no web bridges)
- **Key Features**: HTTP client, persistent storage, navigation, styling

### Mercedes Backend API
```
Base URL: https://api.mercedes-analytics.com
Auth: JWT tokens via cookies
Endpoints:
- POST /admin/login - User authentication
- GET /conversations?cursor={}&limit={} - Paginated conversations
- GET /payments?cursor={}&limit={} - Paginated payments
- GET /metabase/embed/{dashboard_id} - Embedded analytics
- GET/POST/PUT/DELETE /admin/businesses - Business management
```

### Android Requirements
- **Min SDK**: 19 (Android 4.1)
- **Target SDK**: 34 (Android 14)
- **Permissions**: Camera, storage, notifications, biometric
- **Features**: Offline caching, background sync, push notifications

## Development Workflow

### Phase 1: Project Setup
1. Run `valdi dev_setup` to configure development environment
2. Execute `valdi bootstrap` to create project structure
3. Configure BUILD.bazel for Android application
4. Set up module dependencies (valdi_core, valdi_http, valdi_persistence)

### Phase 2: Core Components
1. **Authentication Service**: JWT token management, login/logout
2. **API Service**: HTTP client wrapper with auth headers
3. **Login Screen**: Email/password form with error handling
4. **Dashboard**: Main navigation and overview cards
5. **Data Lists**: Conversations and payments with infinite scroll
6. **Metabase Integration**: Embedded web views for analytics

### Phase 3: Android Features
1. **Permissions**: Runtime permission requests (camera, storage)
2. **Notifications**: Local push notifications for updates
3. **Biometric Auth**: Fingerprint/face unlock as login option
4. **File System**: Document storage and sharing
5. **Sensors**: Device orientation and location (if needed)

### Phase 4: Testing & Deployment
1. **Unit Tests**: Component and service testing
2. **Integration Tests**: API calls and data flow
3. **Build Process**: Debug/release APK generation
4. **Play Store**: Signed bundle upload and store listing
5. **Monitoring**: Crash reporting and analytics

## Code Standards

### Valdi Best Practices
- Use `Component` or `StatefulComponent` for UI elements
- Implement `onRender()` with TSX return syntax
- Create styles at component level, not in render
- Use TypeScript interfaces for ViewModel and State
- Handle lifecycle with `onCreate()`, `onDestroy()`

### Android Integration
- Request permissions before accessing features
- Handle configuration changes (rotation, etc.)
- Implement proper back button navigation
- Use background threads for network operations
- Store sensitive data securely

### API Integration
- Include auth tokens in all authenticated requests
- Implement proper error handling and retry logic
- Use cursor pagination for large datasets
- Cache responses for offline capability
- Validate all API responses

## Quality Assurance

### Testing Requirements
- Unit tests for all components and services
- Integration tests for API calls
- UI tests for critical user flows
- Performance tests for list rendering
- Memory leak detection

### Code Quality
- TypeScript strict mode enabled
- Consistent naming conventions
- Proper error handling
- Code documentation
- Security best practices

## Success Criteria

1. **Functional App**: All core features working on Android devices
2. **API Integration**: Seamless connection to Mercedes backend
3. **User Experience**: Native Android feel with smooth performance
4. **Production Ready**: Signed and deployed to Play Store
5. **Maintainable Code**: Well-structured, documented, and tested

## Documentation References

- `SETUP.md`: Environment setup and project initialization
- `DEVELOPMENT.md`: Component development and Valdi patterns
- `API_INTEGRATION.md`: Backend API integration details
- `ANDROID_SPECIFIC.md`: Android platform features and permissions
- `DEPLOYMENT.md`: Build process and Play Store deployment

## Next Actions Priority

1. **Immediate**: Run `valdi dev_setup` and `valdi bootstrap`
2. **High**: Implement authentication service and login screen
3. **Medium**: Create dashboard and data list components
4. **Low**: Add Android native features and testing

Focus on one feature at a time, ensuring each is fully functional before moving to the next. Always test on real Android devices and handle edge cases properly.