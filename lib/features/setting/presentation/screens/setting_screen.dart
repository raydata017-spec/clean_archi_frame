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
import '../../../../core/utils/enums/alert_layout.dart';
import '../../../../core/utils/extensions/app_bar_extension.dart';
import '../../../../core/utils/extensions/context_extension.dart';
import '../../../../core/utils/extensions/dialog_extension.dart';
import '../../../../shared/widgets/app_selection_bottom_sheet.dart';
import '../widgets/setting_list_tile.dart';
import '../widgets/setting_section_header.dart';

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
          SettingSectionHeader(title: t.setting.general),
          _buildSettingsGroup(
            context,
            children: [
              SettingListTile(
                title: t.setting.changeTheme,
                subtitle: getThemeLabel(themeMode),
                icon: Icons.dark_mode_outlined,
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: AppSizes.iconSm,
                  color: context.colorScheme.onSurface.withValues(alpha: .3),
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
              SettingListTile(
                title: t.setting.changeLanguage,
                subtitle: currentLocale == AppLocale.en ? 'English' : 'မြန်မာ',
                icon: Icons.language_outlined,
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: AppSizes.iconSm,
                  color: context.colorScheme.onSurface.withValues(alpha: .3),
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
          SettingSectionHeader(title: t.setting.notifications),
          _buildSettingsGroup(
            context,
            children: [
              SettingListTile(
                title: t.setting.notificationSetting,
                subtitle: t.setting.manageSystemNotificationPermissions,
                icon: Icons.notifications_none_outlined,
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: AppSizes.iconSm,
                  color: context.colorScheme.onSurface.withValues(alpha: .3),
                ),
                onTap: () => ref
                    .read(permissionServiceProvider)
                    .openAppSettings(AppSettingsType.notification),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.defaultSpace),

          // Section 3: Advanced Settings
          SettingSectionHeader(title: t.setting.advanced),
          _buildSettingsGroup(
            context,
            children: [
              SettingListTile(
                title: t.auth.resetPassword,
                subtitle: t.auth.resetPasswordSubtitle,
                icon: Icons.lock_reset_rounded,
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: AppSizes.iconSm,
                  color: context.colorScheme.onSurface.withValues(alpha: .3),
                ),
                onTap: () {
                  context.push(RouteNames.resetPasswordPath);
                },
              ),
              SettingListTile(
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
              SettingListTile(
                title: t.auth.logout,
                subtitle: t.setting.signOutOfCurrentAccount,
                icon: Icons.logout_rounded,
                iconColor: context.colorScheme.error,
                textColor: context.colorScheme.error,
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: AppSizes.iconSm,
                  color: context.colorScheme.error.withValues(alpha: .3),
                ),
                onTap: () => context.showAppAlert(
                  layout: AlertLayout.bottomSheet,
                  title: t.setting.doYouWantToLogout,
                  content: t.setting.areYouSureYouWantToLogout,
                  confirmColor: context.colorScheme.error,
                  cancelLabel: t.common.cancel,
                  onCancel: () => context.pop(),
                  confirmLabel: t.setting.yesLogout,
                  isConfirmElevated: true,
                  onConfirm: () => context.go(RouteNames.loginPath),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, {required List<Widget> children}) {
    return Column(
      children: children,
    );
  }
}
