import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/dimensions.dart';
import '../../../../app/config/localization/generated/translations.g.dart';
import '../../../../core/utils/extensions/context_extension.dart';

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

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _handleVerify() {
    if (_formKey.currentState!.validate()) {
      widget.onSuccess(context);
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
          onPressed: () {
            context.pop();
          },
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
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleVerify(),
                      style: TextStyle(
                        color: context.colorScheme.onSurface.withValues(alpha: .9),
                        fontSize: AppSizes.fontSizeSm + 1.0,
                      ),
                      decoration: context.inputDecoration(
                        hintText: '123456',
                      ).copyWith(
                        counterText: '',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return t.validation.otpRequired;
                        }
                        if (value.length < 6) {
                          return t.validation.otpInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.paddingMarginXl),

                    // Verify Button
                    SizedBox(
                      height: AppSizes.buttonHeightMd + 8.0, // 48
                      child: ElevatedButton(
                        onPressed: _handleVerify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colorScheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                          ),
                        ),
                        child: Text(
                          t.auth.continueText,
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
