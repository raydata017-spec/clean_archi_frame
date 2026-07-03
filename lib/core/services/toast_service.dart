import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart' as styled;

import '../../app/config/dimensions.dart';
import '../../app/config/localization/generated/translations.g.dart';
import '../../app/router/app_router.dart';
import '../utils/enums/toast_type_enum.dart';
import '../utils/extensions/context_extension.dart';



sealed class ToastService {
  /// Shows a toast with a given message and type.
  static void showToast({
    required String message,
    ToastType type = ToastType.success,
    Duration duration = const Duration(seconds: 4),
  }) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    styled.showToastWidget(
      _ToastWidget(
        message: message,
        type: type,
        onClose: () => styled.ToastManager().dismissAll(showAnim: true),
      ),
      context: context,
      isIgnoring: false,
      animation: styled.StyledToastAnimation.slideFromTop,
      reverseAnimation: styled.StyledToastAnimation.slideToTop,
      position: styled.StyledToastPosition.top,
      duration: duration,
      animDuration: const Duration(milliseconds: 400),
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.fastOutSlowIn,
    );
  }

  /// Shows a success toast.
  static void showSuccessToast({required String message}) {
    showToast(message: message, type: ToastType.success);
  }

  /// Shows an error toast.
  static void showErrorToast({String? errorMessage}) {
    showToast(
      message: errorMessage ?? t.common.somethingWentWrong,
      type: ToastType.error,
    );
  }

  /// Shows a warning toast.
  static void showWarningToast({required String message}) {
    showToast(message: message, type: ToastType.warning);
  }

  /// Shows an info toast.
  static void showInfoToast({required String message}) {
    showToast(message: message, type: ToastType.info);
  }
}

class _ToastWidget extends StatelessWidget {
  final String message;
  final ToastType type;
  final VoidCallback onClose;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final (bgColor, borderColor, iconData) = switch (type) {
      ToastType.success => (
        const Color(0xFFE8F5E9),
        const Color(0xFF4CAF50),
        Icons.check_circle_rounded,
      ),
      ToastType.error => (
        const Color(0xFFFFEBEE),
        const Color(0xFFF44336),
        Icons.cancel_rounded,
      ),
      ToastType.warning => (
        const Color(0xFFFFF3E0),
        const Color(0xFFFF9800),
        Icons.error_rounded,
      ),
      ToastType.info => (
        const Color(0xFFE3F2FD),
        const Color(0xFF2196F3),
        Icons.lightbulb_rounded,
      ),
    };

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMarginLg,
        vertical: AppSizes.paddingMarginSm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMarginMd,
        vertical: AppSizes.paddingMarginSm,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
        border: Border.all(color: borderColor, width: AppSizes.dividerThickness),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(iconData, color: borderColor, size: AppSizes.iconMd),
          const SizedBox(width: AppSizes.spaceBtwItems),
          Expanded(
            child: Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(
                fontSize: AppSizes.fontSizeSm,
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: AppSizes.iconSm, color: Colors.black54),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
