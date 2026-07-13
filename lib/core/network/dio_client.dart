import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config/dimensions.dart';

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

  /// Sends a multipart request to upload images or files.
  /// 
  /// Automatically converts [File] and [List<File>] inside the [data] map
  /// into [MultipartFile]s and validates their size against the maximum limit (5MB).
  Future<Response<T>> multipartRequest<T>(
    String path, {
    required String method,
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final formDataMap = <String, dynamic>{};
      for (final entry in data.entries) {
        final value = entry.value;
        if (value is File) {
          final length = await value.length();
          if (length > AppSizes.maxFileSizeInBytes) {
            throw NetworkException(
              message: 'File "${entry.key}" exceeds the maximum upload limit of 5MB.',
              type: 'fileTooLarge',
            );
          }
          final fileName = value.path.split(Platform.pathSeparator).last;
          formDataMap[entry.key] = await MultipartFile.fromFile(
            value.path,
            filename: fileName,
          );
        } else if (value is List<File>) {
          final multipartFiles = <MultipartFile>[];
          for (final file in value) {
            final length = await file.length();
            if (length > AppSizes.maxFileSizeInBytes) {
              throw NetworkException(
                message: 'One of the files in "${entry.key}" exceeds the maximum upload limit of 5MB.',
                type: 'fileTooLarge',
              );
            }
            final fileName = file.path.split(Platform.pathSeparator).last;
            multipartFiles.add(await MultipartFile.fromFile(
              file.path,
              filename: fileName,
            ));
          }
          formDataMap[entry.key] = multipartFiles;
        } else {
          formDataMap[entry.key] = value;
        }
      }

      final formData = FormData.fromMap(formDataMap);

      final response = await _dio.request<T>(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(
          method: method.toUpperCase(),
          contentType: 'multipart/form-data',
        ),
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
