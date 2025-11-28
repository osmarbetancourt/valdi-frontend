# valdi_mobile — Flutter app scaffold

This folder contains a minimal Flutter start point for Mercedes Analytics Mobile.

Quick notes:
- Run `flutter pub get` from `app/` to fetch packages
- Use `flutter run -d <device>` to run on an emulator or physical device

This scaffold includes:
- `lib/main.dart` — tiny app with a Ping button
- `lib/src/services/api_client.dart` — Dio client skeleton
- `lib/src/services/auth_service.dart` — secure-storage auth stub

Replace the placeholder backend URL in `api_client.dart` with your local backend when developing.
