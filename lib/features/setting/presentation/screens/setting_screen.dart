import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/dimensions.dart';
import '../../../../app/config/localization/generated/translations.g.dart';
import '../../../../app/config/localization/locale_provider.dart';
import '../../../../app/config/theme/theme_provider.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/utils/extensions/app_bar_extension.dart';
import '../../../../core/utils/extensions/context_extension.dart';
import '../../../../shared/widgets/app_selection_bottom_sheet.dart';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final currentLocale = ref.watch(localeControllerProvider);

    String getThemeLabel(ThemeMode mode) {
      switch (mode) {
        case ThemeMode.light:
          return t.setting.lightMode;
        case ThemeMode.dark:
          return t.setting.darkMode;
        case ThemeMode.system:
          return t.setting.systemTheme;
      }
    }

    return Scaffold(
      backgroundColor: context.colors.customBackground,
      appBar: AppBar(
        title: Text(
          t.setting.title,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: context.drawerLeading,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingFromScreenEdge, vertical: AppSizes.paddingMarginSm),
        physics: const BouncingScrollPhysics(),
        children: [
          // Section 1: General Settings
          _buildSectionHeader(context, t.setting.general),
          _buildSettingsGroup(
            context,
            children: [
              _buildListTile(
                context,
                title: t.setting.changeTheme,
                subtitle: getThemeLabel(themeMode),
                icon: Icons.dark_mode_outlined,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      themeMode == ThemeMode.system
                          ? 'SYS'
                          : themeMode == ThemeMode.light
                              ? 'LGT'
                              : 'DRK',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurface.withValues(alpha: .5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingMarginXs),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: AppSizes.iconSm,
                      color: context.colorScheme.onSurface.withValues(alpha: .3),
                    ),
                  ],
                ),
                onTap: () async {
                  final selectedMode = await AppSelectionBottomSheet.show<ThemeMode>(
                    context: context,
                    title: t.setting.selectTheme,
                    items: [
                      SelectionItem(
                        value: ThemeMode.system,
                        label: t.setting.systemTheme,
                        isSelected: themeMode == ThemeMode.system,
                        leading: const Icon(Icons.settings_suggest_outlined),
                      ),
                      SelectionItem(
                        value: ThemeMode.light,
                        label: t.setting.lightMode,
                        isSelected: themeMode == ThemeMode.light,
                        leading: const Icon(Icons.light_mode_outlined),
                      ),
                      SelectionItem(
                        value: ThemeMode.dark,
                        label: t.setting.darkMode,
                        isSelected: themeMode == ThemeMode.dark,
                        leading: const Icon(Icons.dark_mode_outlined),
                      ),
                    ],
                  );

                  if (selectedMode != null) {
                    ref.read(themeControllerProvider.notifier).setThemeMode(selectedMode);
                  }
                },
              ),
              _buildDivider(context),
              _buildListTile(
                context,
                title: t.setting.changeLanguage,
                subtitle: currentLocale == AppLocale.en ? 'English' : 'မြန်မာ',
                icon: Icons.language_outlined,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentLocale == AppLocale.en ? 'EN' : 'MY',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurface.withValues(alpha: .5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingMarginXs),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: AppSizes.iconSm,
                      color: context.colorScheme.onSurface.withValues(alpha: .3),
                    ),
                  ],
                ),
                onTap: () async {
                  final selectedLocale = await AppSelectionBottomSheet.show<AppLocale>(
                    context: context,
                    title: t.setting.selectLanguage,
                    items: [
                      SelectionItem(
                        value: AppLocale.en,
                        label: 'English',
                        isSelected: currentLocale == AppLocale.en,
                        leading: const Text('🇺🇸', style: TextStyle(fontSize: 20)),
                      ),
                      SelectionItem(
                        value: AppLocale.my,
                        label: 'မြန်မာ',
                        isSelected: currentLocale == AppLocale.my,
                        leading: const Text('🇲🇲', style: TextStyle(fontSize: 20)),
                      ),
                    ],
                  );

                  if (selectedLocale != null) {
                    ref.read(localeControllerProvider.notifier).changeLocale(selectedLocale);
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: AppSizes.defaultSpace),

          // Section 2: Notifications
          _buildSectionHeader(context, t.setting.notifications),
          _buildSettingsGroup(
            context,
            children: [
              _buildListTile(
                context,
                title: t.setting.notificationSetting,
                subtitle: 'Manage system notification permissions',
                icon: Icons.notifications_none_outlined,
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: AppSizes.iconSm,
                  color: context.colorScheme.onSurface.withValues(alpha: .3),
                ),
                onTap: () => ref.read(permissionServiceProvider).openAppSettings(AppSettingsType.notification),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.defaultSpace),

          // Section 3: Advanced Settings
          _buildSectionHeader(context, t.setting.advanced),
          _buildSettingsGroup(
            context,
            children: [
              _buildListTile(
                context,
                title: t.setting.offlineSync,
                subtitle: t.setting.offlineSyncSubtitle,
                icon: Icons.sync_rounded,
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: AppSizes.iconSm,
                  color: context.colorScheme.onSurface.withValues(alpha: .3),
                ),
                onTap: () {
                  context.pushNamed(RouteNames.outboxName);
                },
              ),
              _buildDivider(context),
              _buildListTile(
                context,
                title: t.auth.logout,
                subtitle: 'Sign out of current account',
                icon: Icons.logout_rounded,
                iconColor: context.colorScheme.error,
                textColor: context.colorScheme.error,
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: AppSizes.iconSm,
                  color: context.colorScheme.error.withValues(alpha: .3),
                ),
                onTap: () {
                  context.go(RouteNames.loginPath);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.paddingMarginXs,
        bottom: AppSizes.paddingMarginSm,
      ),
      child: Text(
        title.toUpperCase(),
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border.all(
          color: context.colorScheme.onSurface.withValues(alpha: .1),
          width: AppSizes.dividerThickness,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
    Color? iconColor,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceBtwItems,
          vertical: AppSizes.spaceBtwItems,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: AppSizes.iconMd,
              color: iconColor ?? context.colorScheme.onSurface.withValues(alpha: .7),
            ),
            const SizedBox(width: AppSizes.spaceBtwItems),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: textColor?.withValues(alpha: .7) ??
                          context.colorScheme.onSurface.withValues(alpha: .5),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: AppSizes.dividerHeight,
      thickness: AppSizes.dividerThickness,
      indent: AppSizes.defaultSpace * 2.2, // Aligns with title text
      color: context.colorScheme.onSurface.withValues(alpha: .05),
    );
  }
}
