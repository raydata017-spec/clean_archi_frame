import '../../../app/config/localization/generated/translations.g.dart';

class EmailValidator {
  EmailValidator._();

  static final RegExp _emailRegExp = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  static bool isSyntaxValid(String email) {
    if (email.isEmpty) return false;
    return _emailRegExp.hasMatch(email);
  }

  /// Flutter Form (Formal Validator)
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return t.validation.emailRequired;
    }
    if (!_emailRegExp.hasMatch(value.trim())) {
      return t.validation.emailInvalid;
    }
    return null;
  }
}
