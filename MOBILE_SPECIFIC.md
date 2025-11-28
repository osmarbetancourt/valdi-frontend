# Mobile Specifics — Device features & Flutter recommendations

This page describes mobile-native features, permissions, and recommended Flutter plugins for Android and iOS. Use these best practices when implementing camera, biometrics, notifications, background tasks, and platform integration.

Permissions & privacy
- Use the `permission_handler` package to request runtime permissions on Android and iOS.
- Always explain why you need permissions before requesting (UI rationale), and provide graceful fallback if permissions are denied.
- Add clear privacy policy links and keep data minimal. Only request permissions you need.

Camera & photos
- Plugin: `camera` or `image_picker` depending on use case.
  - `camera` gives full control, video capture, camera streams
  - `image_picker` is simple for picking/taking photos
- Android manifest permissions: `CAMERA`, `WRITE_EXTERNAL_STORAGE` (older Android), `READ_EXTERNAL_STORAGE` - adopt scoped storage when possible
- iOS Info.plist keys: `NSCameraUsageDescription`, `NSPhotoLibraryAddUsageDescription`, `NSPhotoLibraryUsageDescription`

Biometrics & local auth
- Plugin: `local_auth` for fingerprint/Face ID and passcode fallback.
- Keep biometric code as optional UX; continue to support password fallback
- Do not assume biometrics are available — fall back to secure login

Notifications & push
- Push messaging: `firebase_messaging` (Firebase) or platform-specific push providers via FCM/APNS. Use push services for background updates and critical alerts.
- Local notifications: `flutter_local_notifications` for scheduling and displaying local notifications
- iOS: request permission dialog for push notifications and register correctly with APNS

Background tasks & synchronization
- Short background tasks (fetching updates) - `background_fetch` or platform-specific APIs
- Long-running or scheduled work (Android) - `workmanager` / Android WorkManager (via plugin) or use platform-native services
- For iOS, background fetch and background processing are more restrictive — use silent push notifications for background sync where appropriate

File system & downloads
- Plugin: `path_provider` to access application directories, `file_picker` or `image_picker` for selecting files
- On Android, prefer scoped storage APIs on Android 11+; avoid broad storage permissions

Network reliability & best practices
- Use Dio or a resilient HTTP client with timeouts, retries and exponential backoff.
- Respect user settings on background data / battery saver modes.

Device sensors & location
- Location: `location` or `geolocator` — ensure you handle permission variants (always vs when-in-use for iOS)
- Provide clear user-facing reasons for requesting precise location data

Security & secure storage
- Use `flutter_secure_storage` for storing sensitive values (tokens or small secrets)
- Avoid storing large sensitive blobs in insecure storage

Platform-specific notes
- Android Manifest modifications live in `/android/app/src/main/AndroidManifest.xml` — add required permissions and `uses-feature` entries for camera or biometrics if applicable
- iOS Info.plist must contain usage description strings for camera, location, microphone, and photo library access

Debugging & testing on real devices
- Test runtime permission flows on real devices before final release
- Check Doze / battery optimization for background tasks on Android devices
- Use TestFlight and internal release tracks for early iOS testers

Recommended plugin list (starting point)
- permission_handler — runtime permissions
- camera / image_picker — photos & camera
- local_auth — biometrics
- firebase_messaging — push notifications
- flutter_local_notifications — local notifications
- path_provider — file system locations
- dio + dio_cookie_manager + cookie_jar — HTTP + cookie storage
- workmanager / background_fetch — background tasks
- flutter_secure_storage — secure local storage

Next step
- When scaffolding features, include manifest / Info.plist snippets for the needed permissions and add small UI flows that explain permission reasons before requesting them.