import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

class AuthService extends ChangeNotifier {
  final _secure = const FlutterSecureStorage();
  final ApiClient _api;

  bool isSignedIn = false;

  AuthService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<void> init() async {
    // Try to load session token or cookie from secure storage.
    final token = await _secure.read(key: 'session_token');
    isSignedIn = token != null && token.isNotEmpty;
    notifyListeners();
  }

  /// Attempts to sign in using the backend login endpoint.
  /// On success stores the access_token and marks signed-in state.
  Future<void> signIn(String username, String password) async {
    final body = await _api.login(username, password);
    final token = body['access_token'] as String? ?? '';
    if (token.isEmpty) throw Exception('No access token returned from login');
    await _secure.write(key: 'session_token', value: token);
    isSignedIn = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _secure.delete(key: 'session_token');
    isSignedIn = false;
    notifyListeners();
  }
}
