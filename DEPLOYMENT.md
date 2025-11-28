# Android App Deployment Guide

## Overview

This guide covers building and deploying the Valdi Android app to the Google Play Store.

## Build Configuration

### Release Build Setup

```python
# BUILD.bazel - Release configuration
valdi_android_application(
    name = "mercedes_app_android_release",
    package = "com.mercedes.analytics",
    title = "Mercedes Analytics",
    modules = [
        "//apps/mercedes_app/src/valdi/mercedes_app",
    ],
    native_deps = [
        "@valdi//valdi",
    ],
    # Release-specific settings
    debug = False,
    min_sdk_version = 19,
    target_sdk_version = 34,
    version_code = 1,
    version_name = "1.0.0",
)
```

### ProGuard Configuration

Create `proguard.cfg` for code obfuscation:

```bash
# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep Valdi runtime classes
-keep class com.snap.valdi.** { *; }

# Keep your app's classes
-keep class com.mercedes.analytics.** { *; }

# Keep data classes for serialization
-keep class com.mercedes.analytics.models.** { *; }
```

## Signing Configuration

### Generate Keystore

```bash
# Generate release keystore
keytool -genkey -v -keystore mercedes-release.keystore -alias mercedes-key -keyalg RSA -keysize 2048 -validity 10000
```

### Store Credentials Securely

```bash
# Create secure properties file
echo "storeFile=../mercedes-release.keystore" > keystore.properties
echo "storePassword=YOUR_STORE_PASSWORD" >> keystore.properties
echo "keyAlias=mercedes-key" >> keystore.properties
echo "keyPassword=YOUR_KEY_PASSWORD" >> keystore.properties
```

**⚠️ Security Warning:** Never commit keystore files or passwords to version control.

## Build Process

### Debug Build

```bash
# Build debug APK
bazel build //apps/mercedes_app:mercedes_app_android
```

### Release Build

```bash
# Build release APK
bazel build //apps/mercedes_app:mercedes_app_android_release

# Build Android App Bundle (AAB)
bazel build //apps/mercedes_app:mercedes_app_android_bundle
```

### Output Locations

- APK: `bazel-bin/apps/mercedes_app/mercedes_app_android.apk`
- AAB: `bazel-bin/apps/mercedes_app/mercedes_app_android_bundle.aab`

## Testing Builds

### Internal Testing

```bash
# Install debug build to connected device
adb install bazel-bin/apps/mercedes_app/mercedes_app_android.apk

# Install release build
adb install bazel-bin/apps/mercedes_app/mercedes_app_android_release.apk
```

### Automated Testing

```bash
# Run unit tests
bazel test //apps/mercedes_app/src/valdi/mercedes_app:test

# Run instrumentation tests
bazel test //apps/mercedes_app:android_instrumentation_tests
```

## Google Play Store Preparation

### App Store Listing

#### Store Listing Information

- **App Name**: Mercedes Analytics
- **Short Description**: Professional analytics dashboard for Mercedes conversations and payments
- **Full Description**: Comprehensive analytics platform providing insights into customer conversations, payment trends, and business performance metrics.
- **Screenshots**: 2-8 screenshots (required)
- **Icon**: 512x512 PNG (required)
- **Feature Graphic**: 1024x500 PNG (optional)
- **Privacy Policy**: URL to privacy policy

#### Screenshots Requirements

- Phone: 1080x1920 or higher
- Tablet: 1200x1920 or higher
- Min 2, Max 8 screenshots
- Show key features and UI

### App Content Rating

- **Content Rating**: Everyone or Teen
- **Category**: Business/Productivity
- **Tags**: analytics, business, dashboard, mercedes

### Pricing and Distribution

- **Price**: Free or Paid
- **Countries**: Select target countries
- **Content Guidelines**: Ensure compliance
- **US Export Laws**: Not applicable for business apps

## Play Store Deployment

### Create Google Play Developer Account

1. Go to [play.google.com/apps/publish](https://play.google.com/apps/publish)
2. Pay $25 one-time registration fee
3. Complete account verification

### Upload App

#### Step 1: Create App

1. Click "Create app"
2. Fill in app details
3. Choose "Internal testing" for initial release

#### Step 2: Upload Bundle/APK

1. Go to "Release" → "Internal testing"
2. Click "Create new release"
3. Upload AAB file (preferred) or APK
4. Add release notes

#### Step 3: Store Listing

1. Go to "Store presence" → "Store listing"
2. Upload screenshots, icon, feature graphic
3. Fill in descriptions and contact info

#### Step 4: Content Rating

1. Go to "Store presence" → "App content"
2. Answer content rating questionnaire
3. Submit for review

### Internal Testing Track

```bash
# Create internal testing release
# Upload AAB to Play Console
# Add tester emails
# Roll out to internal testers
```

### Beta Testing

```bash
# After internal testing approval
# Create beta release
# Expand tester group
# Collect feedback
```

### Production Release

```bash
# Final production release
# Full store listing completion
# Submit for Play Store review
# 1-7 days review process
```

## App Bundle vs APK

### Android App Bundle (AAB) - Recommended

- **Benefits**:
  - Smaller download size
  - Dynamic feature modules
  - Automatic splitting by device
  - Play Store optimization
- **Requirements**: Min API 16 (Android 4.1)

### APK

- **Use Cases**:
  - Sideloading
  - Custom distribution
  - Older devices
- **Limitations**:
  - Larger size
  - No dynamic features
  - Manual optimization

## Version Management

### Version Code and Name

```python
valdi_android_application(
    name = "mercedes_app_android",
    version_code = 1,        # Integer, increment for each release
    version_name = "1.0.0",  # String, user-visible version
)
```

### Version Strategy

- **Major**: Breaking changes (1.0.0 → 2.0.0)
- **Minor**: New features (1.0.0 → 1.1.0)
- **Patch**: Bug fixes (1.0.0 → 1.0.1)
- **Build**: CI builds (1.0.0+123)

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Android Build and Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'

    - name: Setup Bazel
      uses: bazelbuild/setup-bazelisk@v2

    - name: Build Release AAB
      run: bazel build //apps/mercedes_app:mercedes_app_android_bundle

    - name: Sign AAB
      run: |
        # Sign the AAB with keystore
        jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 \
          -keystore keystore.jks \
          mercedes_app_android_bundle.aab \
          mercedes-key

    - name: Upload to Play Store
      uses: r0adkll/upload-google-play@v1
      with:
        serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_SERVICE_ACCOUNT }}
        packageName: com.mercedes.analytics
        releaseFiles: mercedes_app_android_bundle.aab
        track: internal
```

## Monitoring and Analytics

### Crash Reporting

```kotlin
// In native Android code
class MercedesApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        // Initialize crash reporting
        FirebaseCrashlytics.getInstance().setCrashlyticsCollectionEnabled(true)
    }
}
```

### Analytics

```kotlin
// Track app events
FirebaseAnalytics.getInstance(this).logEvent("app_open", null)
FirebaseAnalytics.getInstance(this).logEvent("dashboard_view", bundleOf(
    "user_id" to userId,
    "business_id" to businessId
))
```

## Post-Launch Maintenance

### Update Process

1. Increment version code/name
2. Build new release
3. Test thoroughly
4. Upload to Play Console
5. Roll out gradually (staged rollout)
6. Monitor crash reports and user feedback

### Staged Rollout

- Start with 20% of users
- Monitor crash rates and user feedback
- Gradually increase rollout percentage
- Roll back if issues detected

### User Feedback

- Monitor Play Store reviews
- Set up email for support
- Use Firebase Crashlytics for crash reports
- Implement in-app feedback mechanism

## Performance Optimization

### Bundle Size Optimization

```python
# Minimize included resources
valdi_android_application(
    name = "mercedes_app_android",
    # Only include necessary resources
    resources = glob([
        "res/**/*.xml",
        "res/drawable-*/**/*.png",
    ]),
    # Exclude debug resources
    resources_blacklist = glob([
        "res/**/debug_*",
    ]),
)
```

### Startup Time

- Minimize initial data loading
- Use lazy loading for non-critical features
- Optimize image assets
- Pre-compile shaders if using custom graphics

## Security Considerations

### Code Obfuscation

- Enable ProGuard/R8
- Keep sensitive classes
- Test obfuscated builds

### Network Security

```xml
<!-- AndroidManifest.xml -->
<application
    android:networkSecurityConfig="@xml/network_security_config"
    ...>
```

```xml
<!-- res/xml/network_security_config.xml -->
<network-security-config>
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">mercedes-analytics.com</domain>
    </domain-config>
</network-security-config>
```

### API Key Protection

- Use Play Store signing for API keys
- Never hardcode sensitive keys
- Use certificate pinning for HTTPS

## Success Metrics

### Key Performance Indicators

- **Install Rate**: Downloads per day
- **Retention**: Daily/Weekly active users
- **Crash Rate**: Crashes per user session
- **Rating**: Play Store rating and reviews
- **Revenue**: If monetized

### Monitoring Tools

- Google Play Console analytics
- Firebase Analytics
- Firebase Crashlytics
- Custom business metrics

## Next Steps

- Monitor user feedback
- Plan feature updates
- Prepare for iOS deployment
- Consider expansion to other platforms
