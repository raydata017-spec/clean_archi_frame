import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../app/config/dimensions.dart';
import '../../../../app/config/flavors/flavor_config_provider.dart';
import '../../../../app/config/localization/generated/translations.g.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/services/biometrics_service.dart';
import '../../../../core/utils/enums/auth_type_enum.dart';
import '../../../../core/utils/extensions/context_extension.dart';
import '../../../../shared/widgets/language_icon_button.dart';
import '../providers/biometric_provider.dart';
import '../widgets/email_form.dart';
import '../widgets/phone_form.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final AuthTypeEnum loginType;

  const LoginScreen({
    super.key,
    this.loginType = AuthTypeEnum.both,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.loginType == AuthTypeEnum.phoneOnly ? 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    final appConfig = ref.watch(appConfigProvider);
    final isBiometricEnabled = ref.watch(biometricEnabledProvider);
    final isBiometricSupported = ref.watch(biometricSupportProvider).value ?? false;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: const [
          LanguageIconButton(),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.paddingFromScreenEdge),
            child: Container(
              constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Minimalist Logo Icon
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.bolt_rounded,
                      size: AppSizes.iconLg,
                      color: context.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.defaultSpace),
                  Text(
                    t.auth.signInToConsole,
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingMarginSm),
                  Text(
                    _getSubtitleText(),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurface.withValues(alpha: .5),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingMarginXl),

                  // Minimalist Underline Tab Selector
                  if (widget.loginType == AuthTypeEnum.both) ...[
                    _buildUnderlineSelector(),
                    const SizedBox(height: AppSizes.spaceBtwTextFields),
                  ],

                  // Active Form (Email/Phone)
                  _buildActiveForm(),
                  const SizedBox(height: AppSizes.paddingMarginXl),

                  // Biometric Login Button
                  if (appConfig.isFeatureEnabled('enableBiometrics') &&
                      isBiometricEnabled &&
                      isBiometricSupported) ...[
                    ref.watch(activeBiometricTypeProvider).when(
                          data: (type) {

                            final icon = type == BiometricType.face
                                ? Icons.face_rounded
                                : (type == BiometricType.fingerprint
                                    ? Icons.fingerprint_rounded
                                    : Icons.security_rounded);
                            final label = type == BiometricType.face
                                ? t.setting.faceId
                                : (type == BiometricType.fingerprint
                                    ? t.setting.fingerprint
                                    : t.setting.biometrics);

                            return OutlinedButton.icon(
                              onPressed: () async {
                                final biometrics = ref.read(biometricsServiceProvider);
                                final success = await biometrics.authenticate(
                                  reason: t.auth.biometricReason,
                                );
                                if (success) {
                                  if (context.mounted) {
                                    context.go(RouteNames.homePath);
                                  }
                                }
                              },
                              icon: Icon(
                                icon,
                                color: context.colorScheme.primary,
                                size: AppSizes.iconMd,
                              ),
                              label: Text(
                                label,
                                style: TextStyle(
                                  color: context.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppSizes.fontSizeSm,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSizes.paddingMarginMd,
                                ),
                                side: BorderSide(color: context.colorScheme.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                                ),
                              ),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                    const SizedBox(height: AppSizes.paddingMarginXl),
                  ],

                  // Sign Up Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        t.auth.dontHaveAccount,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurface.withValues(alpha: .5),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go(RouteNames.registerPath);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMarginSm),
                        ),
                        child: Text(
                          t.auth.signUp,
                          style: TextStyle(
                            color: context.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getSubtitleText() {
    switch (widget.loginType) {
      case AuthTypeEnum.emailOnly:
        return t.auth.emailSubtitle;
      case AuthTypeEnum.phoneOnly:
        return t.auth.phoneSubtitle;
      case AuthTypeEnum.both:
        return t.auth.bothSubtitle;
    }
  }

  Widget _buildActiveForm() {
    switch (widget.loginType) {
      case AuthTypeEnum.emailOnly:
        return const EmailForm();
      case AuthTypeEnum.phoneOnly:
        return const PhoneForm();
      case AuthTypeEnum.both:
        return _selectedTab == 0 ? const EmailForm() : const PhoneForm();
    }
  }

  Widget _buildUnderlineSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.colorScheme.onSurface.withValues(alpha: .2),
            width: AppSizes.dividerThickness,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildTabItem(label: t.auth.email, index: 0),
          const SizedBox(width: AppSizes.defaultSpace),
          _buildTabItem(label: t.auth.phone, index: 1),
        ],
      ),
    );
  }

  Widget _buildTabItem({required String label, required int index}) {
    final isActive = _selectedTab == index;
    final activeColor = context.colorScheme.onSurface.withValues(alpha: .9);
    final inactiveColor = context.colorScheme.onSurface.withValues(alpha: .5);

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.cardRadiusMd),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? context.colorScheme.primary : Colors.transparent,
              width: AppSizes.dividerThickness * 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? activeColor : inactiveColor,
            fontSize: AppSizes.fontSizeSm,
          ),
        ),
      ),
    );
  }
}
