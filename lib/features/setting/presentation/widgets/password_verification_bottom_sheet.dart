import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/dimensions.dart';
import '../../../../app/config/localization/generated/translations.g.dart';
import '../../../../core/utils/extensions/context_extension.dart';

class PasswordVerificationBottomSheet extends StatefulWidget {
  const PasswordVerificationBottomSheet({super.key});

  @override
  State<PasswordVerificationBottomSheet> createState() => _PasswordVerificationBottomSheetState();
}

class _PasswordVerificationBottomSheetState extends State<PasswordVerificationBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSizes.paddingFromScreenEdge,
        right: AppSizes.paddingFromScreenEdge,
        top: AppSizes.defaultSpace,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.defaultSpace,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle indicator
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 38.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: context.colorScheme.onSurface.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.defaultSpace),
            Text(
              t.auth.password,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingMarginSm),
            Text(
              t.setting.biometricsPasswordReason,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: .6),
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
            TextFormField(
              controller: _controller,
              obscureText: true,
              decoration: context.inputDecoration(
                hintText: 'Enter password',
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return t.validation.passwordRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => context.pop(false),
                  child: Text(t.common.cancel),
                ),
                const SizedBox(width: AppSizes.paddingMarginSm),
                ElevatedButton(
                  onPressed: () {
                    // Call Back end API for verify password
                    // After success, return true
                    if (_formKey.currentState!.validate()) {
                      context.pop(true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colorScheme.primary,
                    foregroundColor: context.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                    ),
                  ),
                  child: Text(t.common.confirm),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
