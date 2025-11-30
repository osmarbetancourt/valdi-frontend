import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';
import '../models/current_user.dart';

class AuthService extends ChangeNotifier {
  final _secure = const FlutterSecureStorage();
  final ApiClient _api;

  bool isSignedIn = false;
  CurrentUser? currentUser;

  AuthService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<void> init() async {
    // Try to load session token from secure storage.
    final token = await _secure.read(key: 'session_token');
    if (token != null && token.isNotEmpty) {
      // If we have an access token persisted, try to pull user info
      try {
        final me = await _api.me();
        currentUser = CurrentUser.fromMap(me);
        isSignedIn = true;
      } catch (_) {
        isSignedIn = true; // assume token means signed in for now
      }
      notifyListeners();
      return;
    }

    // No persisted token -> attempt cookie-based session check by hitting /admin/auth/me
    try {
      final me = await _api.me();
      currentUser = CurrentUser.fromMap(me);
      isSignedIn = true;
    } catch (_) {
      isSignedIn = false;
    }
    notifyListeners();
  }

  /// Attempts to sign in using the backend login endpoint.
  /// On success stores the access_token and marks signed-in state.
  Future<void> signIn(String username, String password) async {
    final token = await loginRequest(username, password);
    if (token.isEmpty) throw Exception('No access token returned from login');
    await finishSignIn(token);
  }

  /// Perform the login request and return the access token (without storing).
  Future<String> loginRequest(String username, String password) async {
    final body = await _api.login(username, password);
    final token = body['access_token'] as String? ?? '';
    return token;
  }

  /// Finalize sign in by persisting token and notifying listeners.
  Future<void> finishSignIn(String accessToken) async {
    await _secure.write(key: 'session_token', value: accessToken);
    // fetch current user after persisting token
    try {
      final me = await _api.me();
      currentUser = CurrentUser.fromMap(me);
    } catch (_) {
      currentUser = null;
    }

    isSignedIn = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await _api.logout();
    } catch (_) {
      // ignore errors while trying to logout remotely
    }
    await _secure.delete(key: 'session_token');
    // also attempt to clear persisted cookies if present
    try {
      await _api.clearCookies();
    } catch (_) {}

    isSignedIn = false;
    currentUser = null;
    notifyListeners();
  }

  bool hasRole(String role) => currentUser?.hasRole(role) ?? false;

  /// Convenience: whether the current user is any kind of admin.
  bool get isAdmin => currentUser?.roles.any((r) => r.contains('admin')) ?? false;

  /// Expose the ApiClient so callers can reuse the same client (and cookie jar).
  ApiClient get api => _api;
}
