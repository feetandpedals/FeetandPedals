import 'dart:async';

import 'package:dio/dio.dart';

import '../config/env.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

/// Thin wrapper around [Dio], pointed at the Eventiq-backed
/// feetandpedals.com ticketing API.
///
/// Endpoint paths below (`/auth/login`, `/events`, `/orders`, ...) are best
/// guesses at REST conventions and are isolated inside the `*Repository`
/// classes in `lib/data/repositories/` — once the real Eventiq API surface
/// is known, only those repositories need to change, not the UI layer.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.instance.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio _dio;

  Dio get dio => _dio;

  Future<T> request<T>(
    Future<Response<dynamic>> Function(Dio dio) call, {
    required FutureOr<T> Function(dynamic data) parse,
  }) async {
    try {
      final response = await call(_dio);
      return await parse(response.data);
    } on DioException catch (e) {
      throw ApiException(
        _messageFor(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  String _messageFor(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'The request timed out. Please check your connection and try again.';
      case DioExceptionType.connectionError:
        return 'Could not reach the server. Please check your connection.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}
