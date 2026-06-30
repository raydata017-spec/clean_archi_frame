import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/dimensions.dart';
import '../../../../app/config/localization/generated/translations.g.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/utils/extensions/context_extension.dart';

class PhoneForm extends StatefulWidget {
  final bool isSignUp;

  const PhoneForm({
    super.key,
    this.isSignUp = false,
  });

  @override
  State<PhoneForm> createState() => _PhoneFormState();
}

class _PhoneFormState extends State<PhoneForm> {
  final _phoneFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = false;
  String _selectedCountryCode = '+95'; // Default: Myanmar

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handlePhoneSubmit() {
    if (_phoneFormKey.currentState!.validate()) {
      context.go(RouteNames.homePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.auth.phoneNumber,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .9),
            ),
          ),
          const SizedBox(height: AppSizes.paddingMarginSm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Minimalist Dropdown Selector
              Container(
                height: AppSizes.buttonHeightMd + 8.0, // 48
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.cardRadiusMd),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .2),
                    width: AppSizes.dividerThickness,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                ),
                child: Center(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCountryCode,
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      style: TextStyle(
                        fontSize: AppSizes.fontSizeSm,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .9),
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .9),
                        size: AppSizes.iconSm,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCountryCode = newValue;
                          });
                        }
                      },
                      items: <String>['+95', '+66', '+65', '+1', '+91']
                          .map<DropdownMenuItem<String>>((String value) {
                        String flag = '🇲🇲';
                        if (value == '+66') flag = '🇹🇭';
                        if (value == '+65') flag = '🇸🇬';
                        if (value == '+1') flag = '🇺🇸';
                        if (value == '+91') flag = '🇮🇳';
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text('$flag $value'),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.paddingMarginSm),
              // Phone Input Field
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: widget.isSignUp ? TextInputAction.next : TextInputAction.done,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .9),
                    fontSize: AppSizes.fontSizeSm + 1.0,
                  ),
                  decoration: _buildInputDecoration(
                    hintText: '9 1234 5678',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return t.auth.phoneRequired;
                    }
                    if (value.trim().length < 8) {
                      return t.auth.phoneInvalid;
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.fontSizeXl),

          // Password Field for Phone
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.auth.password,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .9),
                ),
              ),
              if (!widget.isSignUp)
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    t.auth.forgotPassword,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
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
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .9),
              fontSize: AppSizes.fontSizeSm + 1.0,
            ),
            onFieldSubmitted: (_) {
              if (!widget.isSignUp) _handlePhoneSubmit();
            },
            decoration: _buildInputDecoration(
              hintText: widget.isSignUp ? 'Choose password' : 'Enter password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .5),
                  size: AppSizes.fontSizeXl,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return t.auth.passwordRequired;
              }
              if (value.length < 6) {
                return t.auth.passwordLengthError;
              }
              return null;
            },
          ),
          
          // Confirm Password Field (Only shown in Sign Up mode)
          if (widget.isSignUp) ...[
            const SizedBox(height: AppSizes.fontSizeXl),
            Text(
              t.auth.confirmPassword,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .9),
              ),
            ),
            const SizedBox(height: AppSizes.paddingMarginSm),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .9),
                fontSize: AppSizes.fontSizeSm + 1.0,
              ),
              onFieldSubmitted: (_) => _handlePhoneSubmit(),
              decoration: _buildInputDecoration(
                hintText: 'Repeat password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .5),
                    size: AppSizes.fontSizeXl,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t.auth.confirmPasswordRequired;
                }
                if (value != _passwordController.text) {
                  return t.auth.passwordsDoNotMatch;
                }
                return null;
              },
            ),
          ],
          
          const SizedBox(height: AppSizes.spaceBtwItems),

          // Remember Me
          if (!widget.isSignUp) ...[
            Row(
              children: [
                SizedBox(
                  height: AppSizes.fontSizeXl,
                  child: Checkbox(
                    value: _rememberMe,
                    activeColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                    ),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .2),
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
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .5),
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
              onPressed: _handlePhoneSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
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

  InputDecoration _buildInputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .5),
        fontSize: AppSizes.fontSizeSm,
        fontWeight: FontWeight.normal,
      ),
      suffixIcon: suffixIcon,
      fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: .9),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceBtwItems,
        vertical: AppSizes.cardRadiusMd,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .2),
          width: AppSizes.dividerThickness,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .2),
          width: AppSizes.dividerThickness,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.error,
          width: AppSizes.dividerThickness,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.error,
          width: 1.5,
        ),
      ),
    );
  }
}