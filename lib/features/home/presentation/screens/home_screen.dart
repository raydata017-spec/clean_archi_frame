import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/dimensions.dart';
import '../../../../app/config/localization/generated/translations.g.dart';
import '../../../../app/config/localization/locale_provider.dart';
import '../../../../app/config/theme/theme_provider.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/utils/extensions/app_bar_extension.dart';
import '../../../../core/utils/extensions/context_extension.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.colors.customBackground,
      appBar: AppBar(
        title: const Text('Theme Architecture'),
        leading: context.drawerLeading,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
            ),
            onPressed: () => context.push(RouteNames.notificationPath),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingFromScreenEdge),
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
              const SizedBox(height: AppSizes.spaceBtwItems),
              // -------------------------------------------
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
