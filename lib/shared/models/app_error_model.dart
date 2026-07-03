import '../../app/config/localization/generated/translations.g.dart';
import '../../core/utils/enums/app_error_type_enum.dart';

class AppError implements Exception {
  final String message;
  final AppErrorType type;

  AppError({required this.message, this.type = AppErrorType.defaultError});

  factory AppError.fromJson(Map<String, dynamic> map) {
    return AppError(
      message: map["message"] ?? t.kDynamic.defaultErrorText,
      type: AppErrorType.defaultError,
    );
  }

  @override
  String toString() => message;
}
