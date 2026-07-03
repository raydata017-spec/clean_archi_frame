import 'package:flutter/material.dart';

import '../../app/config/dimensions.dart';
import '../../app/config/localization/generated/translations.g.dart';
import 'error_service.dart';

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    this.onRetry,
    this.error,
    this.color,
    this.btnColor,
    this.retryBtnText,
  });

  final Function()? onRetry;
  final Object? error;
  final Color? color;
  final Color? btnColor;
  final String? retryBtnText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: AppSizes.spaceBtwButtons,
        children: [
          Text(
            ErrorService.getErrorMessage(
              error ?? t.kDynamic.defaultErrorText,
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color ?? Theme.of(context).colorScheme.error,
            ),
          ),
          if (onRetry != null)
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: btnColor),
              icon: const Icon(Icons.refresh),
              label: Text(retryBtnText ?? t.common.retry),
              onPressed: onRetry,
            ),
        ],
      ),
    );
  }
}
