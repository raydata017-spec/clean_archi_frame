import 'package:logger/logger.dart';

class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  /// Infomation
  static void i(dynamic message) => _logger.i(message);

  /// Debug
  static void d(dynamic message) => _logger.d(message);

  /// Warning
  static void w(dynamic message) => _logger.w(message);

  /// Error
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
