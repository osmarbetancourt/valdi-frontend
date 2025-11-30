import 'dart:io';

import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

class ApiClient {
  late final Dio _dio;
  PersistCookieJar? _cookieJar;
  /// expose the underlying Dio instance for advanced usage
  Dio get dio => _dio;

  /// expose base url
  String get baseUrl => _dio.options.baseUrl;

  ApiClient({String baseUrl = 'https://api-backoffice.mercedes-mb.org'}) {
    _dio = Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 10)));
  }

  /// Creates an [ApiClient] that persists cookies to disk so server-set
  /// session cookies survive app restarts. This is preferred for mobile
  /// when the backend uses cookie-based sessions.
  static Future<ApiClient> createWithCookiePersistence({String baseUrl = 'https://api-backoffice.mercedes-mb.org'}) async {
    final client = ApiClient(baseUrl: baseUrl);
    // Choose the application documents directory to persist cookies.
    final dir = await getApplicationDocumentsDirectory();
    final cookieDir = Directory('${dir.path}/.cookies');
    if (!cookieDir.existsSync()) cookieDir.createSync(recursive: true);
    final jar = PersistCookieJar(storage: FileStorage(cookieDir.path));
    client._cookieJar = jar;
    client._dio.interceptors.add(CookieManager(jar));
    return client;
  }

  /// Performs a GET request to the API root and returns the HTTP status code.
  ///
  /// Use this to check general connectivity (expect 200).
  Future<int> ping() async {
    try {
      final r = await _dio.get('/');
      return r.statusCode ?? 0;
    } on DioException catch (e) {
      // If the server returned a response (4xx/5xx) return its code
      if (e.response != null) return e.response?.statusCode ?? 0;
      // Otherwise rethrow connection/timeout errors for the caller to handle
      rethrow;
    }
  }

  /// Authenticate and return the parsed response body (map). Caller should
  /// handle storage of tokens if necessary.
  Future<Map<String, dynamic>> login(String username, String password) async {
    final r = await _dio.post('/admin/auth/login', data: {'username': username, 'password': password});
    if (r.statusCode == 200) {
      final data = r.data;
      if (data is Map<String, dynamic>) return data;
      return {'access_token': data?.toString() ?? ''};
    }
    throw Exception('Login failed: HTTP ${r.statusCode}');
  }

  /// Get the current authenticated user. Useful to validate cookie sessions.
  Future<Map<String, dynamic>> me() async {
    final r = await _dio.get('/admin/auth/me');
    if (r.statusCode == 200 && r.data is Map<String, dynamic>) return r.data as Map<String, dynamic>;
    throw Exception('me() failed: HTTP ${r.statusCode}');
  }

  /// Logout using the server endpoint and keep client cookies in a consistent state.
  Future<void> logout() async {
    try {
      await _dio.post('/admin/auth/logout');
    } finally {
      // best-effort: clear stored cookies locally
      await clearCookies();
    }
  }

  /// Clear persisted cookies (if any).
  Future<void> clearCookies() async {
    try {
      await _cookieJar?.deleteAll();
    } catch (_) {
      // ignore errors on cookie cleanup
    }
  }
}
