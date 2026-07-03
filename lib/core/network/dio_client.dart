import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/api_error_model.dart';
import '../storage/shared_pref_service.dart';
import 'exceptions/api_exception.dart';
import 'exceptions/network_exception.dart';
import 'exceptions/unauthorized_exception.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logger_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 15),
    contentType: Headers.jsonContentType,
    responseType: ResponseType.json,
  ));

  final sharedPrefs = ref.watch(sharedPrefServiceProvider);

  dio.interceptors.addAll([
    AuthInterceptor(sharedPrefs, dio),
    RetryInterceptor(dio: dio),
    LoggerInterceptor(),
  ]);

  return dio;
});

final dioClientProvider = Provider<DioClient>((ref) {
  final dio = ref.watch(dioProvider);
  return DioClient(dio);
});

class DioClient {
  final Dio _dio;

  DioClient(this._dio);

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Connection timed out. Please try again.');

      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'Secure connection failed. Bad certificate.',
          type: 'badCertificate',
        );

      case DioExceptionType.connectionError:
        return const SocketException('No internet connection. Please check your network.');

      case DioExceptionType.cancel:
        return NetworkException(
          message: 'Request was cancelled.',
          type: 'cancelled',
        );

      case DioExceptionType.badResponse:
        final response = e.response;
        if (response != null) {
          final statusCode = response.statusCode;
          final responseData = response.data;

          ApiError? apiError;
          if (responseData is Map<String, dynamic>) {
            try {
              apiError = ApiError.fromJson(responseData, statusCode: statusCode);
            } catch (_) {
              // Ignore parse errors, let default handle
            }
          }

          if (statusCode == 401) {
            return UnauthorizedException(
              statusCode: statusCode,
              apiError: apiError,
              message: apiError?.displayMessage ?? 'Session expired. Please log in again.',
            );
          }

          if (apiError != null) {
            return ApiException(
              statusCode: statusCode,
              apiError: apiError,
              message: apiError.displayMessage,
            );
          }

          return ApiException(
            statusCode: statusCode,
            message: 'Server returned error status code: $statusCode',
          );
        }
        return ApiException(message: 'Server returned error with no response body.');

      case DioExceptionType.unknown:
      default:
        // Handle SocketException wrapped inside unknown error
        final error = e.error;
        if (error is SocketException) {
          return error;
        }
        return NetworkException(
          message: e.message ?? 'An unexpected network error occurred.',
          type: 'unknown',
        );
    }
  }
}
