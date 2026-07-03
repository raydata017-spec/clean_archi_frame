class ApiError implements Exception {
  String? error;
  String? message;
  String? rootMessage;
  int? statusCode;
  List<ApiErrorDetail>? errorDetail;
  Map<String, dynamic>? data;

  ApiError({
    required this.error,
    required this.message,
    this.rootMessage,
    required this.errorDetail,
    this.statusCode,
    this.data,
  });

  factory ApiError.fromJson(Map<String, dynamic> json, {int? statusCode}) {
    final errorData = json['error'];
    final rootMsg = json['message']?.toString();

    if (errorData is String) {
      return ApiError(
        statusCode: statusCode,
        error: null,
        message: null,
        rootMessage: errorData,
        errorDetail: null,
      );
    }

    return ApiError(
      statusCode: statusCode,
      error: errorData?['code']?.toString(),
      message: errorData?['message']?.toString(),
      rootMessage: rootMsg,
      errorDetail: errorData?['details']
          ?.map<ApiErrorDetail>((detail) => ApiErrorDetail.fromJson(detail))
          .toList(),
      data: errorData?['data'],
    );
  }

  String get displayMessage {
    if (error == 'INTERNAL_SERVER_ERROR') {
      return 'Our servers are currently busy improving your experience. Please try again in a few moments.';
    }

    if (errorDetail != null && errorDetail!.isNotEmpty) {
      final detailMessage = errorDetail!.first.message;
      if (detailMessage != null && detailMessage.isNotEmpty) {
        return detailMessage;
      }
    }
    if (message != null && message!.isNotEmpty) {
      return message!;
    }
    if (rootMessage != null && rootMessage!.isNotEmpty) {
      return rootMessage!;
    }
    return 'There was a problem processing your request. Please try again.';
  }

  @override
  String toString() {
    return 'ApiError{error: $error, message: $message, rootMessage: $rootMessage, statusCode: $statusCode, errorDetail: $errorDetail}';
  }
}

class ApiErrorDetail {
  String? message;
  String? field;
  String? location;

  ApiErrorDetail({
    required this.message,
    required this.field,
    required this.location,
  });

  factory ApiErrorDetail.fromJson(Map<String, dynamic> json) {
    return ApiErrorDetail(
      message: json['message'],
      field: json['field'],
      location: json['location'],
    );
  }

  @override
  String toString() {
    return 'ApiErrorDetail{message: $message, field: $field, location: $location}';
  }
}
