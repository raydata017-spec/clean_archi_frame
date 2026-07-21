import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/dimensions.dart';
import '../../../../app/config/flavors/flavor_config_provider.dart';
import '../../../../app/config/localization/generated/translations.g.dart';
import '../../../../app/config/localization/locale_provider.dart';
import '../../../../app/config/theme/theme_provider.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/services/biometrics_service.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/utils/enums/alert_layout.dart';
import '../../../auth/presentation/providers/biometric_provider.dart';
import '../../../../core/utils/extensions/app_bar_extension.dart';
import '../../../../core/utils/extensions/context_extension.dart';
import '../../../../core/utils/extensions/dialog_extension.dart';
import '../../../../shared/widgets/app_selection_bottom_sheet.dart';
import '../widgets/password_verification_bottom_sheet.dart';
import '../widgets/setting_list_tile.dart';
import '../widgets/setting_section_header.dart';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({super.key});

  Future<bool?> _showPasswordVerificationBottomSheet(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.borderRadiusXl),
          topRight: Radius.circular(AppSizes.borderRadiusXl),
        ),
      ),
      builder: (context) => const PasswordVerificationBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appConfig = ref.watch(appConfigProvider);
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

    String getLocaleLabel(AppLocaleMode mode) {
      switch (mode) {
        case AppLocaleMode.system:
          return t.setting.systemLanguage;
        case AppLocaleMode.english:
          return 'English';
        case AppLocaleMode.burmese:
          return 'မြန်မာ';
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
                subtitle: getLocaleLabel(currentLocale),
                icon: Icons.language_outlined,
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: AppSizes.iconSm,
                  color: context.colorScheme.onSurface.withValues(alpha: .3),
                ),
                onTap: () async {
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
              ),
              if (appConfig.isFeatureEnabled('enableBiometrics') &&
                  (ref.watch(biometricSupportProvider).value ?? false))
                SettingListTile(
                  title: t.setting.biometrics,
                  subtitle: t.setting.biometricsSubtitle,
                  icon: Icons.fingerprint_rounded,
                  trailing: Switch(
                    value: ref.watch(biometricEnabledProvider),
                    activeThumbColor: context.colorScheme.primary,
                    onChanged: (value) async {
                      final biometrics = ref.read(biometricsServiceProvider);
                      final success = await biometrics.authenticate(
                        reason: t.auth.biometricReason,
                      );
                      if (success) {
                        await ref
                            .read(biometricEnabledProvider.notifier)
                            .toggleBiometric(value);
                      } else {
                        if (context.mounted) {
                          final passwordVerified = await _showPasswordVerificationBottomSheet(context);
                          if (passwordVerified == true) {
                            await ref
                                .read(biometricEnabledProvider.notifier)
                                .toggleBiometric(value);
                          }
                        }
                      }
                    },
                  ),
                  onTap: () async {
                    final currentValue = ref.read(biometricEnabledProvider);
                    final newValue = !currentValue;
                    final biometrics = ref.read(biometricsServiceProvider);
                    final success = await biometrics.authenticate(
                      reason: t.auth.biometricReason,
                    );
                    if (success) {
                      await ref
                          .read(biometricEnabledProvider.notifier)
                          .toggleBiometric(newValue);
                    } else {
                      if (context.mounted) {
                        final passwordVerified = await _showPasswordVerificationBottomSheet(context);
                        if (passwordVerified == true) {
                          await ref
                              .read(biometricEnabledProvider.notifier)
                              .toggleBiometric(newValue);
                        }
                      }
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
              SettingListTile(
                title: t.setting.locationSetting,
                subtitle: t.setting.manageSystemLocationPermissions,
                icon: Icons.location_on_outlined,
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: AppSizes.iconSm,
                  color: context.colorScheme.onSurface.withValues(alpha: .3),
                ),
                onTap: () => ref.read(permissionServiceProvider).requestLocationPermission(),
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
              if (appConfig.isFeatureEnabled('enableOfflineSync'))
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
