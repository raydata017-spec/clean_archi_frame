import 'package:flutter/material.dart';

extension DialogContextExtension on BuildContext {
  /// မည်သည့် widget မဆို dialog အဖြစ် ပြသနိုင်သော flexible helper
  ///
  /// Common defaults တစ်နေရာထဲ သတ်မှတ်ထားပြီး caller မှ
  /// [builder] တွင် ကြိုက်သော widget ထည့်ပေးရုံသာ လိုသည်။
  Future<T?> showAppDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useSafeArea = true,
    RouteSettings? routeSettings,
  }) {
    return showDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      useSafeArea: useSafeArea,
      routeSettings: routeSettings,
      builder: builder,
    );
  }
}
