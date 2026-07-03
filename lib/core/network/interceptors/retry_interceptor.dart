import 'package:dio/dio.dart';

const String kRetryAttemptExtra = '_retryAttempt';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    Dio? dio,
    this.maxRetries = 2,
    this.backoffs = const [Duration(milliseconds: 300), Duration(milliseconds: 900)],
  }) : _dio = dio;

  final Dio? _dio;
  final int maxRetries;
  final List<Duration> backoffs;

  static const _idempotentMethods = {'GET', 'PUT', 'DELETE'};

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    final options = err.requestOptions;
    final attempt = (options.extra[kRetryAttemptExtra] as int?) ?? 0;
    if (attempt >= maxRetries) {
      handler.next(err);
      return;
    }

    final delay = attempt < backoffs.length ? backoffs[attempt] : backoffs.last;
    await Future<void>.delayed(delay);

    options.extra[kRetryAttemptExtra] = attempt + 1;
    try {
      final dio = _dio ?? Dio(BaseOptions(baseUrl: options.baseUrl));
      final response = await dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    if (!_idempotentMethods.contains(err.requestOptions.method.toUpperCase())) {
      return false;
    }
    // Only retry on network-level errors where the server never received/answered.
    // Do NOT retry on server error responses (4xx/5xx) — those are deliberate
    // responses and retrying just compounds load / delays the error state.
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;
  }
}
