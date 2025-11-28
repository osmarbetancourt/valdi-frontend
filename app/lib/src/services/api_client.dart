import 'package:dio/dio.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({String baseUrl = 'https://api-backoffice.mercedes-mb.org'}) {
    _dio = Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 10)));
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
}
