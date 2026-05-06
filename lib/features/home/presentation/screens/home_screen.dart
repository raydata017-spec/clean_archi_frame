import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/config/localization/generated/translations.g.dart';
import '../../../../app/config/localization/locale_provider.dart';
import '../../../../app/config/theme/theme_provider.dart';
import '../../../../core/utils/extensions/context_extension.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // context.colors (Custom extension)
      backgroundColor: context.colors.customBackground,
      appBar: AppBar(title: const Text('Theme Architecture')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dynamic translation with parameters
            Text(
              t.kDynamic.welcomeMessage(name: 'Kaung Mrat', point: 1500),
            ),
            Text(
              t.kDynamic.inboxCount(n: 10),
            ),
            // -------------------------------------------
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton(
                  // context.colorScheme (Material default)
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colorScheme.primary,
                  ),
                  onPressed: () {
                    ref.read(themeControllerProvider.notifier).toggleTheme();
                  },
                  child: Text(
                    t.setting.changeTheme,
                    style: TextStyle(color: context.colorScheme.onPrimary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final currentLocale = LocaleSettings.currentLocale;
                    final newLocale = currentLocale == AppLocale.en ? AppLocale.my : AppLocale.en;

                    ref.read(localeControllerProvider.notifier).changeLocale(newLocale);
                  },
                  child: Text(
                    t.setting.changeLanguage,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
