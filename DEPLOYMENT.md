# Deployment — Producing release artifacts & publishing

This guide describes how to create release builds and publish the Flutter app to Google Play and App Store.

Android (Play Store)
1. App signing (recommended)
  - Play App Signing: upload your app bundle, Play will manage signing keys.
  - Or manage your own signing keys locally via `key.jks`.

2. Build an AAB (App Bundle)
```bash
# debug
flutter build apk --debug
# release app bundle
flutter build appbundle --release
```

3. Configure keystore for signing
- Store your keystore (e.g., `android/key.jks`) outside source control and provide signing configs in `/android/key.properties`.
- Add to `android/app/build.gradle` signing configs and use Gradle tasks to produce signed bundles

4. Upload to Play Console
- Create app on Play Console and publish to internal testing track, then to closed / open tracks as required.

5. Versioning & Play Console
- Update `versionCode` (int) and `versionName` in `android/app/build.gradle` or via `pubspec.yaml` version

iOS (App Store)
1. Requirements
- MacOS and Xcode
- Apple Developer account and App Store Connect access

2. Certificates & provisioning
- Use Xcode or `fastlane match` to manage signing certificates and provisioning profiles

3. Archive & upload
```bash
# create an Xcode archive and export
flutter build ipa --release
# or use Xcode Organizer
```

4. Distribute via TestFlight and App Store
- Upload via Xcode or Transporter and create TestFlight builds for testers

Continuous Integration (recommended)
- Automate builds, tests and artifact creation using GitHub Actions, Bitrise, or CircleCI.
- Example CI steps:
  - Setup Flutter environment (use `subosito/flutter-action` in GitHub Actions or FVM)
  - flutter pub get
  - flutter analyze
  - flutter test
  - Build artifacts (AAB for Android, IPA for iOS)
  - (Optional) Deploy to internal testing tracks or TestFlight using credentials stored in CI secrets

Crash reporting & monitoring
- Use Sentry or Firebase Crashlytics for crash reporting.
- Integrate performance monitoring and analytics to track slow sections and user behavior.

App Signing & secrets
- Never commit keystores or signing credentials to the repository.
- Store keys and credentials in a secrets store (GitHub Secrets, Bitrise secrets, Vault) and inject at build time.

Release checklist
- Ensure ProGuard/R8 rules are configured for any platform-specific 3rd-party native libs
- Test on a set of real devices and OS versions
- Confirm backend version compatibility (API schema, authentication changes)
- Verify crash reporting and monitoring are enabled for the released binaries

Rollout & hotfix strategy
- Start with internal testing → closed track → gradual rollout
- Prepare hotfix process and CI ability to cut new production builds quickly

If you'd like, I can create example GitHub Actions workflows for Android (app bundle), iOS (ipa via macOS runners), and example scripts to manage keystore injection into CI.