import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../utils/logger/app_logger.dart';

class LoggerInterceptor extends Interceptor {
  LoggerInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      AppLogger.d(
          '[HTTP →] ${options.method} ${options.uri}${_formatBody(options.data)}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      AppLogger.d(
          '[HTTP ←] ${response.statusCode} ${response.requestOptions.uri}${_formatBody(response.data)}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      AppLogger.e(
        '[HTTP ✗] ${err.requestOptions.method} ${err.requestOptions.uri} → ${err.response?.statusCode ?? err.type.name}${_formatBody(err.response?.data)}',
      );
    }
    handler.next(err);
  }

  String _formatBody(Object? data) {
    if (data == null) return '';

    try {
      // If the data is a JSON object or array, pretty-print it with indentations
      if (data is Map || data is List) {
        final prettyString = const JsonEncoder.withIndent('  ').convert(data);
        return '\n$prettyString';
      }

      // Fallback for raw text/html
      final text = data.toString();
      if (text.isEmpty) return '';
      return '\n$text';
    } catch (e) {
      // If parsing fails, return standard string
      return '\n${data.toString()}';
    }
  }
}