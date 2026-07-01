import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/dimensions.dart';
import '../../../../app/config/localization/generated/translations.g.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/utils/enums/auth_type_enum.dart';
import '../../../../core/utils/extensions/context_extension.dart';
import '../../../../shared/widgets/phone_input_field.dart';

class RegisterScreen extends StatefulWidget {
  final AuthTypeEnum loginType;

  const RegisterScreen({
    super.key,
    this.loginType = AuthTypeEnum.both,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  // Current wizard step: 0 = Details, 1 = Password
  int _currentStep = 0;

  // Step 1 Controllers & States
  int _selectedTab = 0; // 0 = Email, 1 = Phone
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedCountryCode = '+95';
  bool _acceptTerms = false;
  bool _showTermsError = false;

  // Step 2 Controllers & States
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.loginType == AuthTypeEnum.phoneOnly ? 1 : 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _goToStep2() {
    setState(() {
      _showTermsError = !_acceptTerms;
    });

    if (_step1FormKey.currentState!.validate() && _acceptTerms) {
      setState(() {
        _currentStep = 1;
      });
    }
  }

  void _handleRegisterSubmit() {
    if (_step2FormKey.currentState!.validate()) {
      context.go(RouteNames.homePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(AppSizes.paddingFromScreenEdge),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState:
                    _currentStep == 0 ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                firstChild: _buildStep1(),
                secondChild: _buildStep2(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Step 1: Details Form ---
  Widget _buildStep1() {
    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo Icon
          Align(
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.bolt_rounded,
              size: AppSizes.iconLg,
              color: context.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSizes.defaultSpace),
          Text(
            t.auth.createAccount,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMarginSm),
          Text(
            t.auth.step1Subtitle,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: .5),
            ),
          ),
          const SizedBox(height: AppSizes.paddingMarginXl),

          // Full Name Input
          Text(
            t.auth.fullName,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.onSurface.withValues(alpha: .9),
            ),
          ),
          const SizedBox(height: AppSizes.paddingMarginSm),
          TextFormField(
            controller: _nameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            style: TextStyle(
              color: context.colorScheme.onSurface.withValues(alpha: .9),
              fontSize: AppSizes.fontSizeSm + 1.0,
            ),
            decoration: context.inputDecoration(hintText: 'John Doe'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return t.auth.nameRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSizes.fontSizeXl),

          // Underline Tab Selector
          if (widget.loginType == AuthTypeEnum.both) ...[
            _buildUnderlineSelector(),
            const SizedBox(height: AppSizes.fontSizeXl),
          ],

          // Dynamic field Email/Phone
          if (_selectedTab == 0 && widget.loginType != AuthTypeEnum.phoneOnly)
            _buildEmailField()
          else
            _buildPhoneField(),
          const SizedBox(height: AppSizes.fontSizeXl),

          // Terms & Conditions Checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: AppSizes.fontSizeXl,
                width: AppSizes.fontSizeXl,
                child: Checkbox(
                  value: _acceptTerms,
                  activeColor: context.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                  ),
                  side: BorderSide(
                    color: _showTermsError
                        ? context.colorScheme.error
                        : context.colorScheme.onSurface.withValues(alpha: .2),
                    width: 1.5,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _acceptTerms = value ?? false;
                      if (_acceptTerms) _showTermsError = false;
                    });
                  },
                ),
              ),
              const SizedBox(width: AppSizes.paddingMarginSm),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _acceptTerms = !_acceptTerms;
                      if (_acceptTerms) _showTermsError = false;
                    });
                  },
                  child: Text(
                    t.auth.termsOfService,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: _showTermsError
                          ? context.colorScheme.error
                          : context.colorScheme.onSurface.withValues(alpha: .6),
                      fontSize: AppSizes.fontSizeSm,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_showTermsError) ...[
            const SizedBox(height: AppSizes.paddingMarginXs),
            Padding(
              padding: const EdgeInsets.only(left: AppSizes.defaultSpace + 4.0),
              child: Text(
                t.auth.termsError,
                style: TextStyle(
                  color: context.colorScheme.error,
                  fontSize: AppSizes.fontSizeXs,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSizes.paddingMarginXl),

          // Continue Button
          SizedBox(
            height: AppSizes.buttonHeightMd + 8.0, // 48
            child: ElevatedButton(
              onPressed: _goToStep2,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colorScheme.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                ),
              ),
              child: Text(
                t.auth.continueText,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.fontSizeSm + 1.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingMarginXl),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${t.auth.alreadyHaveAccount} ",
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: .5),
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.go(RouteNames.loginPath);
                },
                child: Text(
                  t.auth.signIn,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Step 2: Create Password Form ---
  Widget _buildStep2() {
    return Form(
      key: _step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Back button
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: context.colorScheme.onSurface.withValues(alpha: .9),
                size: AppSizes.fontSizeXl,
              ),
              onPressed: () {
                setState(() {
                  _currentStep = 0;
                });
              },
            ),
          ),
          const SizedBox(height: AppSizes.paddingMarginSm),

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
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.fontSizeSm + 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
          decoration: context.inputDecoration(hintText: 'name@company.com'),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return t.auth.emailRequired;
            }
            final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegExp.hasMatch(value.trim())) {
              return t.auth.emailInvalid;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return PhoneInputField(
      controller: _phoneController,
      initialCountryCode: _selectedCountryCode,
      onCountryCodeChanged: (code) {
        _selectedCountryCode = code;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildUnderlineSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.colorScheme.onSurface.withValues(alpha: .2),
            width: AppSizes.dividerThickness,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildTabItem(label: t.auth.email, index: 0),
          const SizedBox(width: AppSizes.defaultSpace),
          _buildTabItem(label: t.auth.phone, index: 1),
        ],
      ),
    );
  }

  Widget _buildTabItem({required String label, required int index}) {
    final isActive = _selectedTab == index;
    final activeColor = context.colorScheme.onSurface.withValues(alpha: .9);
    final inactiveColor = context.colorScheme.onSurface.withValues(alpha: .5);

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.cardRadiusMd),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? context.colorScheme.primary : Colors.transparent,
              width: AppSizes.cardElevation,
            ),
          ),
        ),
        child: Text(
          label,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? activeColor : inactiveColor,
            fontSize: AppSizes.fontSizeSm + 1.0,
          ),
        ),
      ),
    );
  }

}
