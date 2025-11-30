import 'package:dio/dio.dart';
import '../services/api_client.dart';

/// Lightweight admin repository for basic CRUD calls against admin endpoints.
/// Uses the shared ApiClient (with cookie persistence) supplied by AuthService.
class AdminRepository {
  final ApiClient api;

  AdminRepository({required this.api});

  Dio get _dio => api.dio;

  Future<List<Map<String, dynamic>>> fetchBusinesses({int limit = 50}) async {
    final r = await _dio.get('/admin/businesses', queryParameters: {'limit': limit});
    if (r.statusCode == 200 && r.data is List) {
      return (r.data as List).cast<Map<String, dynamic>>();
    }
    throw DioException(requestOptions: r.requestOptions, response: r);
  }

  Future<List<Map<String, dynamic>>> fetchUsers({int limit = 50}) async {
    final r = await _dio.get('/admin/users', queryParameters: {'limit': limit});
    if (r.statusCode == 200 && r.data is List) {
      return (r.data as List).cast<Map<String, dynamic>>();
    }
    throw DioException(requestOptions: r.requestOptions, response: r);
  }

  Future<List<Map<String, dynamic>>> fetchPayments({int limit = 50}) async {
    final r = await _dio.get('/admin/payments', queryParameters: {'limit': limit});
    if (r.statusCode == 200 && r.data is List) {
      return (r.data as List).cast<Map<String, dynamic>>();
    }
    throw DioException(requestOptions: r.requestOptions, response: r);
  }

  /// Create/Update/Delete methods are placeholders to expand later.
  Future<Map<String, dynamic>> createBusiness(Map<String, dynamic> payload) async {
    final r = await _dio.post('/admin/businesses', data: payload);
    if (r.statusCode == 201 || r.statusCode == 200) return r.data as Map<String, dynamic>;
    throw DioException(requestOptions: r.requestOptions, response: r);
  }

  Future<void> deleteBusiness(String id) async {
    await _dio.delete('/admin/businesses/$id');
  }
}
