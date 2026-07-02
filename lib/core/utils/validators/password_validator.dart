import '../../../app/config/localization/generated/translations.g.dart';

class PasswordValidator {
  PasswordValidator._();

  /// Validates standard password strength (min 8 chars, 1 uppercase, 1 digit)
  static String? validate(String? password) {
    if (password == null || password.isEmpty) {
      return t.validation.passwordRequired;
    }
    if (password.length < 8) {
      return t.validation.passwordTooShort;
    }
    if (!password.contains(RegExp(r'[A-Z]')) || !password.contains(RegExp(r'[0-9]'))) {
      return t.validation.passwordWeakText;
    }
    return null;
  }

  /// Validates that a new password is not the same as the old one, and is strong
  static String? validateNewPasswordWithOldPassword(String? oldPassword, String? newPassword) {
    if (newPassword == null || newPassword.isEmpty) {
      return t.validation.passwordRequired;
    }
    if (newPassword == oldPassword) {
      return t.validation.newPasswordSameAsOld;
    }
    return validate(newPassword);
  }

  /// Validates that password and confirmPassword match
  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return t.validation.confirmPasswordRequired;
    }
    if (password != confirmPassword) {
      return t.validation.passwordsDoNotMatch;
    }
    return null;
  }
}
