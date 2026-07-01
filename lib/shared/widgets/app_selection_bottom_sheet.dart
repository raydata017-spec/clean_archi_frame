import 'package:flutter/material.dart';

import '../../app/config/dimensions.dart';
import '../../core/utils/extensions/context_extension.dart';

class SelectionItem<T> {
  final T value;
  final String label;
  final Widget? leading;
  final bool isSelected;

  const SelectionItem({
    required this.value,
    required this.label,
    this.leading,
    this.isSelected = false,
  });
}

class AppSelectionBottomSheet<T> extends StatelessWidget {
  final String title;
  final List<SelectionItem<T>> items;
  final ValueChanged<T> onSelected;

  const AppSelectionBottomSheet({
    super.key,
    required this.title,
    required this.items,
    required this.onSelected,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<SelectionItem<T>> items,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.borderRadiusXl),
          topRight: Radius.circular(AppSizes.borderRadiusXl),
        ),
      ),
      builder: (context) {
        return AppSelectionBottomSheet<T>(
          title: title,
          items: items,
          onSelected: (value) {
            Navigator.pop(context, value);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSizes.paddingMarginSm),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colorScheme.onSurface.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSizes.paddingMarginMd),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMarginMd),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingMarginSm),
          Divider(color: context.colorScheme.onSurface.withValues(alpha: .1)),
          ...items.map((item) {
            return ListTile(
              leading: item.leading,
              title: Text(
                item.label,
                style: TextStyle(
                  fontWeight: item.isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: item.isSelected
                  ? Icon(
                      Icons.check_rounded,
                      color: context.colorScheme.primary,
                      size: AppSizes.iconMd,
                    )
                  : null,
              onTap: () => onSelected(item.value),
            );
          }),
        ],
      ),
    );
  }
}
