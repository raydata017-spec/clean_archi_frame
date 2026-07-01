import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/dimensions.dart';
import '../../../../app/config/localization/generated/translations.g.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/utils/enums/auth_type_enum.dart';
import '../../../../core/utils/extensions/context_extension.dart';
import '../widgets/email_form.dart';
import '../widgets/phone_form.dart';

class LoginScreen extends StatefulWidget {
  final AuthTypeEnum loginType;

  const LoginScreen({
    super.key,
    this.loginType = AuthTypeEnum.both, // Default is both, configurable per project
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Tab State: 0 = Email, 1 = Phone
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    // Dynamically set the initial tab depending on configuration
    _selectedTab = widget.loginType == AuthTypeEnum.phoneOnly ? 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(AppSizes.paddingFromScreenEdge),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
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
                      color: Theme.of(context).colorScheme.primary,
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
                  const SizedBox(height: AppSizes.spaceBtwTexts - 2),
                  Text(
                    _getSubtitleText(),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .5),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingMarginXl),

                  // Minimalist Underline Tab Selector
                  if (widget.loginType == AuthTypeEnum.both) ...[
                    _buildUnderlineSelector(),
                    const SizedBox(height: AppSizes.paddingMarginXl),
                  ],

                  // Form Views
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _buildActiveForm(),
                  ),
                  const SizedBox(height: AppSizes.paddingMarginXl),

                  // Register Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${t.auth.dontHaveAccount} ",
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .5),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.go(RouteNames.registerPath);
                        },
                        child: Text(
                          t.auth.signUp,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
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

  // Subtitle Configuration Helper
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

  // Active Form Selector
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

  // Minimalist Underline Tab Selector
  Widget _buildUnderlineSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .2),
            width: AppSizes.dividerThickness,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildTabItem(
            label: t.auth.email,
            index: 0,
          ),
          const SizedBox(width: AppSizes.defaultSpace),
          _buildTabItem(
            label: t.auth.phone,
            index: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String label,
    required int index,
  }) {
    final isActive = _selectedTab == index;
    final activeColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: .9);
    final inactiveColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: .5);

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.cardRadiusMd),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? Theme.of(context).colorScheme.primary : Colors.transparent,
              width: AppSizes.cardElevation,
            ),
          ),
        ),
        child: Text(
          label,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? activeColor : inactiveColor,
            fontSize: AppSizes.fontSizeSm + 1.0,
          ),
        ),
      ),
    );
  }
}
