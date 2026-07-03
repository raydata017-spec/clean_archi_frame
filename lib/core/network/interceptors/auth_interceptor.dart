import 'package:dio/dio.dart';
import '../../storage/shared_pref_service.dart';

const String kIsPublicExtra = 'isPublic';

class AuthInterceptor extends QueuedInterceptor {
  final SharedPrefService _sharedPrefService;
  final Dio _dio;
  final String refreshPath;

  AuthInterceptor(
    this._sharedPrefService,
    this._dio, {
    this.refreshPath = '/auth/refresh',
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final isPublic = options.extra[kIsPublicExtra] as bool? ?? false;
    if (isPublic) {
      return handler.next(options);
    }

    final token = _sharedPrefService.getAuthToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only intercept 401 Unauthorized errors
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final options = err.requestOptions;
    final isPublic = options.extra[kIsPublicExtra] as bool? ?? false;

    // Do not attempt to refresh for public endpoints or if it's already a refresh request itself
    if (isPublic || options.path.contains(refreshPath)) {
      return handler.next(err);
    }

    final refreshToken = _sharedPrefService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      // No refresh token available, logout and forward the error
      await _handleLogout();
      return handler.next(err);
    }

    try {
      // Perform token refresh using a clean, isolated Dio client to avoid interceptor loop
      final refreshDio = Dio(BaseOptions(
        baseUrl: _dio.options.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      final response = await refreshDio.post<Map<String, dynamic>>(
        refreshPath,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        
        // Extract new tokens (support standard snake_case and camelCase formats)
        final newAccessToken = data['accessToken']?.toString() ?? 
                               data['access_token']?.toString() ?? 
                               data['data']?['accessToken']?.toString() ??
                               data['data']?['access_token']?.toString();

        final newRefreshToken = data['refreshToken']?.toString() ?? 
                                data['refresh_token']?.toString() ??
                                data['data']?['refreshToken']?.toString() ??
                                data['data']?['refresh_token']?.toString();

        if (newAccessToken != null) {
          await _sharedPrefService.saveAuthToken(newAccessToken);
          if (newRefreshToken != null) {
            await _sharedPrefService.saveRefreshToken(newRefreshToken);
          }

          // Update the authorization header for the original failed request
          options.headers['Authorization'] = 'Bearer $newAccessToken';

          // Retry the request using the main Dio instance
          final retryResponse = await _dio.fetch<dynamic>(options);
          return handler.resolve(retryResponse);
        }
      }

      // If refresh failed to return tokens, clear session and reject request
      await _handleLogout();
      return handler.next(err);
    } catch (e) {
      // If refresh call throws an error, clear session and reject request
      await _handleLogout();
      return handler.next(err);
    }
  }

  Future<void> _handleLogout() async {
    await _sharedPrefService.deleteAuthToken();
    await _sharedPrefService.deleteRefreshToken();
    // Session expiration events can be dispatched here if needed
  }
}
