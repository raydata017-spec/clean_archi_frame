import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../app/config/dimensions.dart';
import '../../../../app/config/localization/generated/translations.g.dart';
import '../../../../core/utils/extensions/context_extension.dart';
import '../../../../core/utils/validators/otp_validator.dart';
import '../../../../shared/widgets/app_button.dart';

class OtpScreen extends StatefulWidget {
  final String verificationTarget;
  final void Function(BuildContext) onSuccess;

  const OtpScreen({
    super.key,
    required this.verificationTarget,
    required this.onSuccess,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleVerify() {
    if (_formKey.currentState!.validate()) {
      widget.onSuccess(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: AppSizes.textFieldHeight,
      height: AppSizes.textFieldHeight,
      textStyle: TextStyle(
        fontSize: AppSizes.fontSizeXl,
        color: context.colorScheme.onSurface.withValues(alpha: .9),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: context.colorScheme.onSurface.withValues(alpha: .2),
          width: AppSizes.dividerThickness,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        color: context.colorScheme.surface,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: context.colorScheme.primary,
          width: 1.5,
        ),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: context.colorScheme.onSurface.withValues(alpha: .03),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: context.colorScheme.error,
          width: 1.5,
        ),
      ),
    );

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
            context.pop();
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
                    Icons.domain_verification_rounded,
                    size: AppSizes.iconLg,
                    color: context.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSizes.defaultSpace),
                Text(
                  t.auth.enterOtpCode,
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMarginSm),
                Text(
                  '${t.auth.otpSubtitle}\n(${widget.verificationTarget})',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: .5),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMarginXl),

                // OTP field
                Text(
                  t.auth.otp,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colorScheme.onSurface.withValues(alpha: .9),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMarginSm),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Pinput(
                    length: 6,
                    controller: _otpController,
                    focusNode: _focusNode,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    errorPinTheme: errorPinTheme,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    showCursor: true,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    onCompleted: (_) => _handleVerify(),
                    errorTextStyle: TextStyle(
                      color: context.colorScheme.error,
                      fontSize: AppSizes.fontSizeSm,
                    ),
                    validator: OtpValidator.validate,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMarginXl),

                // Verify Button
                AppButton(
                  btnTitle: t.auth.continueText,
                  btnTextStyle: TextStyle(
                    color: context.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizes.fontSizeSm + 1.0,
                    letterSpacing: 0.2,
                  ),
                  btnFunction: _handleVerify,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
