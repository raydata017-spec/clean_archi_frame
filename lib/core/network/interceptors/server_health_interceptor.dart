// import 'package:dio/dio.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../services/server_health_service.dart';

// class ServerHealthInterceptor extends Interceptor {
//   final Ref ref;

//   ServerHealthInterceptor(this.ref);

//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) {
//     if (_isServerDownError(err)) {
//       // Notify the service that the server is down
//       ref.read(serverHealthProvider.notifier).setServerDown();
//     }
//     super.onError(err, handler);
//   }

//   bool _isServerDownError(DioException err) {
//     // Check if it's a 502, 503, or 504 status code
//     if (err.response != null) {
//       final statusCode = err.response?.statusCode;
//       if (statusCode == 502  statusCode == 503  statusCode == 504) {
//         return true;
//       }
//     }
//     // Alternatively, if it's a connection timeout, it might mean the server is down
//     if (err.type == DioExceptionType.connectionTimeout || 
//         err.type == DioExceptionType.receiveTimeout) {
//       return true;
//     }

//     // Connection error (e.g. DNS failure) might also indicate server is down,
//     // but the OfflineBannerWrapper handles no internet. If there's internet but 
//     // a connection error, it could be server down. We'll include it.
//     if (err.type == DioExceptionType.connectionError) {
//        return true;
//     }
//     return false;
//   }
// }
