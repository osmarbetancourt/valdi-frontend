# Flutter App — Developer Setup

This document explains how to set up the development environment to work on the Mercedes Analytics Flutter mobile client (Android & iOS).

Note: Use macOS if you need to build and publish iOS binaries. Linux/Windows can build and run Android apps but cannot produce App Store signed packages.

Prerequisites
- 8+ GB RAM recommended (more for emulators / simulators)
- Git
- A supported JDK (OpenJDK 11 or 17) — required by Android toolchain
- Flutter SDK (stable channel recommended)
- Android SDK and command-line tools
- Xcode (macOS) for iOS development

1) Install Flutter SDK
- Official guide: https://flutter.dev/docs/get-started/install
- Choose your platform and follow the steps to install Flutter and add it to your PATH.

Example (Linux, fish shell):
```fish
# download (example for Linux x64):
mkdir -p $HOME/sdk
cd $HOME/sdk
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_*.tar.xz
tar xf flutter_linux_*.tar.xz
# add to PATH (permanent, fish):
set -Ux PATH $HOME/sdk/flutter/bin $PATH
flutter --version
```

2) Android toolchain (all platforms)
- Install Android SDK command-line tools and recommended packages
- Recommended packages: `platform-tools`, an SDK platform (e.g. android-34), `build-tools` (latest), `ndk` (for native if needed)

Using Android Studio (easiest):
- Install Android Studio and use its SDK Manager to install required SDKs and create an Android Virtual Device (AVD).

CLI install (Linux example):
```bash
# assume $ANDROID_HOME is set to ~/Android/Sdk
mkdir -p ~/Android/Sdk/cmdline-tools
cd ~/Android/Sdk/cmdline-tools
# download command line tools zip for linux
wget https://dl.google.com/android/repository/commandlinetools-linux-*.zip -O cmdline-tools.zip
unzip cmdline-tools.zip
mv cmdline-tools latest
# add to PATH (fish):
set -Ux ANDROID_HOME $HOME/Android/Sdk
set -Ux PATH $ANDROID_HOME/cmdline-tools/latest/bin $ANDROID_HOME/platform-tools $PATH
# accept licenses and install packages
sdkmanager --sdk_root=$ANDROID_HOME --install "platform-tools" "platforms;android-34" "build-tools;34.0.0" "ndk;25.2.9519653"
sdkmanager --sdk_root=$ANDROID_HOME --licenses
```

3) iOS toolchain (macOS only)
- Install Xcode from the App Store
- Install Xcode command-line tools: `xcode-select --install`
- Install CocoaPods: `sudo gem install cocoapods` (or use brew / Ruby manager)

4) Flutter doctor — validation
```bash
flutter doctor -v
# Resolve warnings or missing dependencies (Android SDK path, Xcode licenses, missing tools)
```

5) Create or configure a device/emulator
- Android: create an AVD in Android Studio or use `flutter emulators` to list and start an emulator:
```bash
flutter emulators --create --name pixel_android_34  # or create via Android Studio
flutter emulators --launch pixel_android_34
flutter run
```
- iOS: open the iOS simulator (macOS only):
```bash
open -a Simulator
flutter run -d ios
```

6) Connect the app to the existing backend
- The backend base URL must be configurable via environment at runtime or via a configuration file.
- Example approaches:
  - Define a compile-time environment variable with flutter_dotenv, or use runtime configuration fetched at first launch.
  - For local development connect mobile emulator to a local backend via:
    - Android emulator: `10.0.2.2` points to host machine (for the default Android emulator)
    - iOS simulator: `localhost` or `127.0.0.1` works for the host machine
  - Use ngrok or a reverse proxy to expose your local backend to devices.

7) Local secrets for development
- Use `.env` or secure local files excluded from git to store API base URLs and other non-sensitive development toggles.
- Do NOT commit real production secrets to the repository. Use CI secrets for production signing and credentials.

8) Useful debugging tools & tips
- Enable Flutter DevTools (hot reload/hot restart)
- Use `flutter logs` and `adb logcat` for Android logs
- For iOS, use `Console` app or `flutter logs` to capture device logs

9) Recommended extras
- Install `FVM` (Flutter Version Manager) for consistent team Flutter versions
- Use `git` pre-commit hooks to run `dart format` and `flutter analyze`

Next step
- After this setup, open the new app scaffold at `/app` and run `flutter pub get` and `flutter run` there. See DEVELOPMENT.md for architecture and code guidelines and API_INTEGRATION.md for connecting to the Mercedes analytics API.