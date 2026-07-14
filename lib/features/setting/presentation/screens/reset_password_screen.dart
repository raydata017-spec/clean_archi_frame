import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/dimensions.dart';
import '../../../../app/config/localization/generated/translations.g.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/utils/extensions/context_extension.dart';
import '../../../../core/utils/validators/password_validator.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            t.auth.resetPassword,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            t.validation.newPasswordSameAsOld == 'New password cannot be the same as old password'
                ? 'Password has been reset successfully.'
                : 'စကားဝှက်ကို အောင်မြင်စွာ ပြောင်းလဲပြီးပါပြီ။',
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
                context.go(RouteNames.loginPath);
              },
              child: Text(
                t.common.cancel == 'Cancel' ? 'OK' : 'ကောင်းပြီ',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.colorScheme.onSurface.withValues(alpha: .9),
            size: AppSizes.fontSizeXl,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(AppSizes.paddingFromScreenEdge),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo Icon
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.vpn_key_rounded,
                        size: AppSizes.iconLg,
                        color: context.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.defaultSpace),
                    Text(
                      t.auth.resetPassword,
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingMarginSm),
                    Text(
                      t.auth.resetPasswordSubtitle,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurface.withValues(alpha: .5),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingMarginXl),

                    // New Password
                    Text(
                      t.auth.password,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colorScheme.onSurface.withValues(alpha: .9),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingMarginSm),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(
                        color: context.colorScheme.onSurface.withValues(alpha: .9),
                        fontSize: AppSizes.fontSizeSm + 1.0,
                      ),
                      decoration: context.inputDecoration(
                        hintText: 'Enter new password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: context.colorScheme.onSurface.withValues(alpha: .5),
                            size: AppSizes.fontSizeXl,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: PasswordValidator.validate,
                    ),
                    const SizedBox(height: AppSizes.fontSizeXl),

                    // Confirm Password
                    Text(
                      t.auth.confirmPassword,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colorScheme.onSurface.withValues(alpha: .9),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingMarginSm),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleResetPassword(),
                      style: TextStyle(
                        color: context.colorScheme.onSurface.withValues(alpha: .9),
                        fontSize: AppSizes.fontSizeSm + 1.0,
                      ),
                      decoration: context.inputDecoration(
                        hintText: 'Repeat new password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: context.colorScheme.onSurface.withValues(alpha: .5),
                            size: AppSizes.fontSizeXl,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) => PasswordValidator.validateConfirmPassword(
                        _passwordController.text,
                        value,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingMarginXl),

                    // Submit Button
                    SizedBox(
                      height: AppSizes.buttonHeightMd + 8.0, // 48
                      child: ElevatedButton(
                        onPressed: _handleResetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colorScheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                          ),
                        ),
                        child: Text(
                          t.auth.resetPassword,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizes.fontSizeSm + 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
