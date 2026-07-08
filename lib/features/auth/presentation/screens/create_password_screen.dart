import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/dimensions.dart';
import '../../../../app/config/localization/generated/translations.g.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/utils/extensions/context_extension.dart';
import '../../../../core/utils/validators/password_validator.dart';

class CreatePasswordScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;

  const CreatePasswordScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
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

  void _handleRegisterSubmit() {
    if (_formKey.currentState!.validate()) {
      context.go(RouteNames.homePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
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
        child: Center(
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
                        Icons.lock_outline_rounded,
                        size: AppSizes.iconLg,
                        color: context.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.defaultSpace),
                    Text(
                      t.auth.password,
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingMarginSm),
                    Text(
                      t.auth.step2Subtitle,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurface.withValues(alpha: .5),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingMarginXl),

                    // Password
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
                        hintText: 'Choose a password',
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
                      style: TextStyle(
                        color: context.colorScheme.onSurface.withValues(alpha: .9),
                        fontSize: AppSizes.fontSizeSm + 1.0,
                      ),
                      onFieldSubmitted: (_) => _handleRegisterSubmit(),
                      decoration: context.inputDecoration(
                        hintText: 'Repeat password',
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
                        onPressed: _handleRegisterSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colorScheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                          ),
                        ),
                        child: Text(
                          t.auth.createAccount,
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
