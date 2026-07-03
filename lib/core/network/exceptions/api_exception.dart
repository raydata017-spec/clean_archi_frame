import '../../../shared/models/api_error_model.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String? message;
  final ApiError? apiError;

  ApiException({
    this.statusCode,
    this.message,
    this.apiError,
  });

  @override
  String toString() {
    return apiError?.displayMessage ?? message ?? 'API Exception occurred';
  }
}
