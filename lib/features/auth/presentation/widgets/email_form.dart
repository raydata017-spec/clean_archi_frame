import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/dimensions.dart';
import '../../../../app/config/localization/generated/translations.g.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/utils/extensions/context_extension.dart';
import '../../../../core/utils/validators/email_validator.dart';
import '../../../../core/utils/validators/password_validator.dart';

class EmailForm extends StatefulWidget {
  final bool isSignUp;

  const EmailForm({
    super.key,
    this.isSignUp = false,
  });

  @override
  State<EmailForm> createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleEmailSubmit() {
    if (_emailFormKey.currentState!.validate()) {
      context.go(RouteNames.homePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Address
          Text(
            t.auth.emailAddress,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.onSurface.withValues(alpha: .9),
            ),
          ),
          const SizedBox(height: AppSizes.paddingMarginSm),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            style: TextStyle(
              color: context.colorScheme.onSurface.withValues(alpha: .9),
              fontSize: AppSizes.fontSizeSm + 1.0,
            ),
            decoration: context.inputDecoration(
              hintText: 'name@company.com',
            ),
            validator: EmailValidator.validate,
          ),
          const SizedBox(height: AppSizes.fontSizeXl),

          // Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.auth.password,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.onSurface.withValues(alpha: .9),
                ),
              ),
              if (!widget.isSignUp)
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    t.auth.forgotPassword,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: AppSizes.fontSizeSm,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMarginSm),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: widget.isSignUp ? TextInputAction.next : TextInputAction.done,
            style: TextStyle(
              color: context.colorScheme.onSurface.withValues(alpha: .9),
              fontSize: AppSizes.fontSizeSm + 1.0,
            ),
            onFieldSubmitted: (_) {
              if (!widget.isSignUp) _handleEmailSubmit();
            },
            decoration: context.inputDecoration(
              hintText: widget.isSignUp ? 'Choose password' : 'Enter password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
          
          // Confirm Password Field (Only shown in Sign Up mode)
          if (widget.isSignUp) ...[
            const SizedBox(height: AppSizes.fontSizeXl),
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
              onFieldSubmitted: (_) => _handleEmailSubmit(),
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
          ],
          
          const SizedBox(height: AppSizes.spaceBtwItems),

          // Remember Me (Only show Keep me signed in on login page)
          if (!widget.isSignUp) ...[
            Row(
              children: [
                SizedBox(
                  height: AppSizes.fontSizeXl,
                  child: Checkbox(
                    value: _rememberMe,
                    activeColor: context.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                    ),
                    side: BorderSide(
                      color: context.colorScheme.onSurface.withValues(alpha: .2),
                      width: 1.5,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMarginSm),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _rememberMe = !_rememberMe;
                    });
                  },
                  child: Text(
                    t.auth.keepMeSignedIn,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurface.withValues(alpha: .5),
                      fontSize: AppSizes.fontSizeSm,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.defaultSpace + 4.0), // 28
          ] else ...[
            const SizedBox(height: AppSizes.borderRadiusLg),
          ],

          // Submit Button
          SizedBox(
            height: AppSizes.buttonHeightMd + 8.0, // 48
            child: ElevatedButton(
              onPressed: _handleEmailSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colorScheme.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                ),
              ),
              child: Text(
                widget.isSignUp ? t.auth.createAccount : t.auth.signIn,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.fontSizeSm + 1.0,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
