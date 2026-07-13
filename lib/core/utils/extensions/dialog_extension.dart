import 'package:flutter/material.dart';

import '../enums/alert_layout.dart';
import '../../../../shared/widgets/app_alert_dialog.dart';
import '../../../../shared/widgets/app_alert_bottom_sheet.dart';
import '../../../../app/config/dimensions.dart';

extension DialogContextExtension on BuildContext {
  /// Dialog သို့မဟုတ် BottomSheet ပုံစံဖြင့် Alert များကို ပြသပေးသော flexible helper
  Future<T?> showAppAlert<T>({
    required String title,
    required String content,
    AlertLayout layout = AlertLayout.dialog,
    TextAlign? contentAlign,
    VoidCallback? onConfirm,
    String confirmLabel = 'OK',
    Color? confirmColor,
    VoidCallback? onCancel,
    String cancelLabel = 'Cancel',
    Color? cancelColor,
    bool barrierDismissible = true,
    bool isConfirmElevated = false,
    bool isCancelElevated = false,
  }) {
    if (layout == AlertLayout.bottomSheet) {
      return showModalBottomSheet<T>(
        context: this,
        backgroundColor: Theme.of(this).colorScheme.surface,
        isDismissible: barrierDismissible,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSizes.borderRadiusXl),
            topRight: Radius.circular(AppSizes.borderRadiusXl),
          ),
        ),
        builder: (context) => AppAlertBottomSheet(
          title: title,
          content: content,
          contentAlign: contentAlign,
          onConfirm: onConfirm,
          confirmLabel: confirmLabel,
          confirmColor: confirmColor,
          onCancel: onCancel,
          cancelLabel: cancelLabel,
          cancelColor: cancelColor,
          isConfirmElevated: isConfirmElevated,
          isCancelElevated: isCancelElevated,
        ),
      );
    } else {
      return showDialog<T>(
        context: this,
        barrierDismissible: barrierDismissible,
        builder: (context) => AppAlertDialog(
          title: title,
          content: content,
          contentAlign: contentAlign,
          onConfirm: onConfirm,
          confirmLabel: confirmLabel,
          confirmColor: confirmColor,
          onCancel: onCancel,
          cancelLabel: cancelLabel,
          cancelColor: cancelColor,
          isConfirmElevated: isConfirmElevated,
          isCancelElevated: isCancelElevated,
        ),
      );
    }
  }
}
