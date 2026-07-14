import '../../../app/config/localization/generated/translations.g.dart';

class OtpValidator {
  OtpValidator._();

  /// Validates that an OTP is not null/empty and is exactly 6 digits.
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return t.validation.otpRequired;
    }
    if (value.trim().length < 6) {
      return t.validation.otpInvalid;
    }
    return null;
  }
}
