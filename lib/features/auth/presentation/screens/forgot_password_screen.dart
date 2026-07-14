import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/dimensions.dart';
import '../../../../app/config/localization/generated/translations.g.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/utils/enums/auth_type_enum.dart';
import '../../../../core/utils/extensions/context_extension.dart';
import '../../../../core/utils/validators/email_validator.dart';
import '../../../../core/utils/validators/phone_validator.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/phone_input_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final AuthTypeEnum loginType;

  const ForgotPasswordScreen({
    super.key,
    this.loginType = AuthTypeEnum.both,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  int _selectedTab = 0; // 0 = Email, 1 = Phone
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedCountryCode = '+95';

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.loginType == AuthTypeEnum.phoneOnly ? 1 : 0;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSendCode() {
    if (_formKey.currentState!.validate()) {
      context.push(
        RouteNames.otpPath,
        extra: {
          'verificationTarget': _getIdentifier(),
          'onSuccess': (BuildContext otpContext) {
            otpContext.pop(); // Pop OTP screen
            context.pushReplacement(RouteNames.resetPasswordPath);
          },
        },
      );
    }
  }

  String _getIdentifier() {
    if (_selectedTab == 0 && widget.loginType != AuthTypeEnum.phoneOnly) {
      return _emailController.text.trim();
    }
    return '$_selectedCountryCode ${_phoneController.text.trim()}';
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
          onPressed: () {
            context.go(RouteNames.loginPath);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(AppSizes.paddingFromScreenEdge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo Icon
                Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    Icons.lock_open_rounded,
                    size: AppSizes.iconLg,
                    color: context.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSizes.defaultSpace),
                Text(
                  t.auth.forgotPassword,
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMarginSm),
                Text(
                  t.auth.forgotPasswordSubtitle,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: .5),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMarginXl),

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
                const SizedBox(height: AppSizes.paddingMarginXl),

                // Send Code Button
                AppButton(
                  btnTitle: t.auth.sendCode,
                  btnTextStyle: TextStyle(
                    color: context.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizes.fontSizeSm + 1.0,
                    letterSpacing: 0.2,
                  ),
                  btnFunction: _handleSendCode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helpers ---
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
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleSendCode(),
          style: TextStyle(
            color: context.colorScheme.onSurface.withValues(alpha: .9),
            fontSize: AppSizes.fontSizeSm + 1.0,
          ),
          decoration: context.inputDecoration(hintText: 'name@company.com'),
          validator: EmailValidator.validate,
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
      textInputAction: TextInputAction.done,
      validator: PhoneValidator.validate,
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
