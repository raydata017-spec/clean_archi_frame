import 'dart:async';
import 'dart:developer';
import 'dart:io';

import '../../shared/models/api_error_model.dart';
import '../../shared/models/app_error_model.dart';
import '../utils/enums/error_type_enum.dart';
import '../services/toast_service.dart';

class UIError {
  final ErrorType type;
  final String title;
  final String message;

  const UIError({
    required this.type,
    required this.title,
    required this.message,
  });
}

class ErrorService {
  /// Get a structured UIError object to determine which widget to show
  static UIError getUIError(Object error) {
    final type = getErrorType(error);
    final message = getErrorMessage(error);
    String title;

    switch (type) {
      case ErrorType.noInternet:
        title = 'No Connection';
        break;
      case ErrorType.serverError:
        title = 'Server Error';
        break;
      case ErrorType.timeout:
        title = 'Timeout';
        break;
      case ErrorType.formatError:
        title = 'Data Error';
        break;
      case ErrorType.apiError:
        title = 'Error';
        break;
      case ErrorType.unknown:
        title = 'Something went wrong';
        break;
    }

    return UIError(type: type, title: title, message: message);
  }

  /// Determine the type of error for UI switching
  static ErrorType getErrorType(Object error) {
    if (error is SocketException) {
      return ErrorType.noInternet;
    }
    if (error is TimeoutException) {
      return ErrorType.timeout;
    }
    if (error is HttpException) {
      return ErrorType.serverError;
    }
    if (error is FormatException) {
      // Check if it's actually a server error (HTML response instead of JSON)
      final source = (error.source ?? '').toString().toLowerCase();
      if (source.contains('<!doctype html') || source.contains('<html')) {
        return ErrorType.serverError;
      }
      return ErrorType.formatError;
    }
    if (error is ApiError) {
      if (error.statusCode != null && error.statusCode! >= 500) {
        return ErrorType.serverError;
      }
      return ErrorType.apiError;
    }
    return ErrorType.unknown;
  }

  /// Show an error toast based on the type of error
  static void showErrorToast(Object error, [StackTrace? stackTrace]) {
    final errorMessage = getErrorMessage(error);
    ToastService.showErrorToast(errorMessage: errorMessage);
  }

  /// Convert any error object into a user-friendly message
  static String getErrorMessage(Object error) {
    log('Error RuntimeType: ${error.runtimeType}');

    if (error is String) {
      if (error == 'Internal Server Error' || error == 'INTERNAL_SERVER_ERROR') {
        return 'Our servers are currently busy improving your experience. Please try again in a few moments.';
      }
      return error;
    }

    if (error is ApiError) {
      return error.displayMessage;
    }

    if (error is AppError) {
      return error.message;
    }

    // Dynamic fallback for potential split-identity types (relative vs package imports)
    try {
      final errorStr = error.runtimeType.toString();
      if (errorStr == 'AppError' || errorStr == '_AppError') {
        return (error as dynamic).message;
      }
      if (errorStr == 'ApiError' || errorStr == '_ApiError') {
        return (error as dynamic).displayMessage;
      }
    } catch (_) {
      // Ignore dynamic access errors and fall through
    }

    if (error is HttpException) {
      return error.message;
    }

    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    }

    if (error is FormatException) {
      return _handleFormatException(error);
    }

    if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    }

    if (error is Exception || error is Error) {
      return _cleanExceptionMessage(error.toString());
    }

    return 'An unexpected error occurred.';
  }

  /// Special handling for FormatException (e.g., HTML instead of JSON)
  static String _handleFormatException(FormatException error) {
    // final msg = error.message.toLowerCase();
    final source = (error.source ?? '').toString().toLowerCase();

    // Detect if the server returned HTML instead of JSON
    if (source.contains('<!doctype html') || source.contains('<html')) {
      // Try to detect specific error codes inside the HTML
      if (source.contains('502')) {
        return 'Server Error: Bad Gateway (502). Please try again later.';
      }
      if (source.contains('503')) {
        return 'Server Error: Service Unavailable (503). Please try again later.';
      }
      if (source.contains('500')) {
        return 'Our servers are currently busy improving your experience. Please try again in a few moments.';
      }

      return 'Server Error: Received invalid response (HTML instead of JSON). Please try again later.';
    }

    return 'Invalid data format received.';
  }

  /// Convert Exception into a user-friendly message
  static String getErrorMessageFromException(Exception exception) {
    if (exception is ApiError) {
      return exception.displayMessage;
    }

    if (exception is SocketException) {
      return 'Network Error: Please check your internet connection.';
    }

    if (exception is FormatException) {
      return _handleFormatException(exception);
    }

    if (exception is TimeoutException) {
      return 'Request Timeout: The server took too long to respond.';
    }

    // Fallback for any other exceptions
    final message = _cleanExceptionMessage(exception.toString());
    log('Unhandled Exception: ${exception.runtimeType}', error: exception);
    return message;
  }

  /// Utility to strip out "ExceptionType: " prefixes for cleaner messages
  static String _cleanExceptionMessage(String message) {
    final colonIndex = message.indexOf(':');
    if (colonIndex != -1 &&
        colonIndex < message.length - 1 &&
        message.substring(0, colonIndex).contains(RegExp(r'[A-Za-z]+'))) {
      return message.substring(colonIndex + 1).trim();
    }
    return message;
  }
}
