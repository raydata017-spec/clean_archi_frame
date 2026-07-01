import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/dimensions.dart';
import '../../../../app/config/localization/generated/translations.g.dart';
import '../../../../app/config/localization/locale_provider.dart';
import '../../../../app/config/theme/theme_provider.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/utils/extensions/context_extension.dart';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final currentLocale = ref.watch(localeControllerProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: context.colors.customBackground,
      appBar: AppBar(
        title: Text(t.setting.title),
      ),
      body: ListView(
        padding: EdgeInsets.all(AppSizes.paddingFromScreenEdge),
        children: [
          SwitchListTile(
            title: Text(t.setting.changeTheme),
            subtitle: Text(isDarkMode ? t.setting.darkMode : t.setting.lightMode),
            value: isDarkMode,
            onChanged: (_) {
              ref.read(themeControllerProvider.notifier).toggleTheme();
            },
          ),
          ListTile(
            title: Text(t.setting.changeLanguage),
            subtitle: Text(
              currentLocale == AppLocale.en ? 'English' : 'မြန်မာ',
            ),
            trailing: const Icon(Icons.language),
            onTap: () {
              final newLocale = currentLocale == AppLocale.en ? AppLocale.my : AppLocale.en;
              ref.read(localeControllerProvider.notifier).changeLocale(newLocale);
            },
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.sync),
            title: Text(t.setting.offlineSync),
            subtitle: Text(t.setting.offlineSyncSubtitle),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              context.pushNamed(RouteNames.outboxName);
            },
          ),

          // Log out
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(t.auth.logout),
            onTap: () {
              context.go(RouteNames.loginPath);
            },
          ),
        ],
      ),
    );
  }
}
