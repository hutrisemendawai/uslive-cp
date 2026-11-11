import 'package:dio/dio.dart';

class ApiClient {
  ApiClient(String baseUrl)
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );

  final Dio _dio;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
    );
    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? data,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(path, data: data);
    return response.data ?? <String, dynamic>{};
  }
}
