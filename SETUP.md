# Valdi Android App Setup Guide

## Overview

This guide covers setting up the Valdi framework for developing an Android app that integrates with the Mercedes analytics backend API.

## Prerequisites

### System Requirements

- macOS (recommended) or Linux
- Android Studio (latest version)
- Xcode (macOS only, for iOS development if needed)

### Valdi CLI Installation

```bash
npm install -g @snap/valdi
```

### Development Environment Setup

```bash
valdi dev_setup
```

This command installs:

- Homebrew (macOS)
- Bazelisk (build system)
- Java JDK 17
- Android SDK command-line tools
- Git LFS
- Watchman
- iOS debugging tools (macOS)

### Verify Setup

```bash
valdi doctor
```

## Android-Specific Setup

### Android SDK Configuration

The `valdi dev_setup` command configures:

- `ANDROID_HOME`: Points to Android SDK location
- `ANDROID_NDK_HOME`: Points to Android NDK
- `PATH`: Includes platform-tools for ADB

### Environment Variables (macOS)

```bash
echo "export ANDROID_HOME=$HOME/Library/Android/sdk" >> ~/.zshrc
echo "export ANDROID_NDK_HOME=$HOME/Library/Android/Sdk/ndk/25.2.9519653" >> ~/.zshrc
echo "export PATH=\$PATH:$HOME/Library/Android/sdk/platform-tools" >> ~/.zshrc
source ~/.zshrc
```

### Java JDK Setup

Valdi requires Java 17. The setup installs OpenJDK 17 and configures:

- `JAVA_HOME`: Points to JDK location
- `PATH`: Includes Java tools

## Project Initialization

### Create New Valdi Project

```bash
mkdir valdi-mercedes-app
cd valdi-mercedes-app
valdi bootstrap
```

### Project Structure

```bash
valdi-mercedes-app/
├── MODULE.bazel          # Bazel workspace configuration
├── WORKSPACE.bazel       # Bazel workspace (generated)
├── apps/
│   └── mercedes_app/     # Main app module
│       ├── BUILD.bazel
│       ├── module.yaml
│       ├── src/
│       │   └── valdi/
│       │       └── mercedes_app/
│       │           ├── src/
│       │           │   └── App.tsx
│       │           ├── res/        # Images/assets
│       │           ├── strings/    # Localization
│       │           └── tsconfig.json
├── valdi/                # Valdi framework (external)
└── third-party/          # Dependencies
```

## Android Build Configuration

### Module Configuration (module.yaml)

```yaml
name: mercedes_app
version: 1.0.0
dependencies:
  - valdi_core
  - valdi_http
  - valdi_persistence
```

### BUILD.bazel Configuration

```python
load("@valdi//bzl/valdi:valdi_android_application.bzl", "valdi_android_application")

valdi_android_application(
    name = "mercedes_app_android",
    package = "com.mercedes.analytics",
    title = "Mercedes Analytics",
    modules = [
        "//apps/mercedes_app/src/valdi/mercedes_app",
    ],
    native_deps = [
        "@valdi//valdi",
    ],
)
```

## First Build and Install

### Build for Android

```bash
valdi install android
```

Select the target: `//apps/mercedes_app:mercedes_app_android`

### Connect Device/Emulator

- Start Android emulator via Android Studio
- Or connect physical Android device with USB debugging enabled

### Verify Installation

The app should install and launch automatically after build completion.

## Development Workflow

### Hot Reloading

```bash
valdi hotreload --module mercedes_app
```

This enables real-time updates as you modify TypeScript code.

### VS Code Setup (Recommended)

1. Install VS Code
2. Add to PATH: `code` command
3. Install Valdi VS Code extension (if available)

## Troubleshooting

### Common Issues

#### Build Failures

```bash
# Clean and rebuild
bazel clean
valdi install android
```

#### Android SDK Issues

```bash
# Check Android SDK
echo $ANDROID_HOME
ls $ANDROID_HOME

# Accept SDK licenses
$ANDROID_HOME/tools/bin/sdkmanager --licenses
```

#### Java Version Issues

```bash
# Check Java version
java -version
echo $JAVA_HOME

# Switch Java version (macOS)
export JAVA_HOME=`/usr/libexec/java_home -v 17`
```

#### Device Connection Issues

```bash
# List connected devices
adb devices

# Restart ADB
adb kill-server
adb start-server
```

### Getting Help

- Run `valdi doctor` for diagnostics
- Check [Valdi Troubleshooting Guide](https://github.com/Snapchat/Valdi/blob/main/docs/TROUBLESHOOTING.md)
- Join [Discord community](https://discord.gg/uJyNEeYX2U)

## Next Steps

- [Development Guide](./DEVELOPMENT.md)
- [API Integration](./API_INTEGRATION.md)
- [Android Specific Features](./ANDROID_SPECIFIC.md)
