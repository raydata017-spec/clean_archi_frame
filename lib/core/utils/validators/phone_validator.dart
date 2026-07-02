import '../../../app/config/localization/generated/translations.g.dart';

class PhoneValidator {
  PhoneValidator._();

  /// Form validator for Myanmar phone numbers.
  /// Validates presence, prefix (+959), and length (12 to 15 digits).
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty || value.trim() == t.validation.phoneCountryCode) {
      return t.validation.phoneRequired;
    }

    final trimmedValue = value.trim();
    if (!trimmedValue.startsWith(t.validation.phoneCountryCode)) {
      return t.validation.phoneStartWith;
    }

    if (trimmedValue.length < 12 || trimmedValue.length > 15) {
      return t.validation.phoneInvalid;
    }

    return null;
  }
}
