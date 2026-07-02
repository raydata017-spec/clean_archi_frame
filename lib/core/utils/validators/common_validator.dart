import '../../../app/config/localization/generated/translations.g.dart';

class CommonValidator {
  CommonValidator._();

  /// Validates that a field is not null or empty, with an optional max length
  static String? validateNotNullable(String? value, String name, {int? maxLength}) {
    if (value == null || value.trim().isEmpty) {
      return t.validation.fieldRequired(name: name);
    }
    if (maxLength != null && value.length > maxLength) {
      return '$name must be less than $maxLength characters';
    }
    return null;
  }

  /// Validates OTP code (must be exactly 6 digits)
  static String? validateOtp(String? otp) {
    if (otp == null || otp.trim().isEmpty) {
      return t.validation.otpRequired;
    }
    if (otp.trim().length != 6) {
      return t.validation.otpInvalid;
    }
    return null;
  }
}
