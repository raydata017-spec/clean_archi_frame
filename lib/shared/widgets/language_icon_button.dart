import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config/dimensions.dart';
import '../../app/config/localization/generated/translations.g.dart';
import '../../app/config/localization/locale_provider.dart';
import '../../core/utils/extensions/context_extension.dart';
import 'app_selection_bottom_sheet.dart';

class LanguageIconButton extends ConsumerWidget {
  const LanguageIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeControllerProvider);

    return IconButton(
      icon: Icon(
        Icons.translate_rounded,
        color: context.colorScheme.onSurface.withValues(alpha: .9),
        size: AppSizes.iconMd,
      ),
      onPressed: () async {
        final selectedLocale = await AppSelectionBottomSheet.show<AppLocaleMode>(
          context: context,
          title: t.setting.selectLanguage,
          items: [
            SelectionItem(
              value: AppLocaleMode.system,
              label: t.setting.systemLanguage,
              isSelected: currentLocale == AppLocaleMode.system,
              leading: const Icon(Icons.settings_suggest_outlined),
            ),
            SelectionItem(
              value: AppLocaleMode.english,
              label: 'English',
              isSelected: currentLocale == AppLocaleMode.english,
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 20)),
            ),
            SelectionItem(
              value: AppLocaleMode.burmese,
              label: 'မြန်မာ',
              isSelected: currentLocale == AppLocaleMode.burmese,
              leading: const Text('🇲🇲', style: TextStyle(fontSize: 20)),
            ),
          ],
        );

        if (selectedLocale != null) {
          ref.read(localeControllerProvider.notifier).changeLocale(selectedLocale);
        }
      },
    );
  }
}
