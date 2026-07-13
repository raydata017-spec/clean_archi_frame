import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/assets.dart';
import '../../../../app/config/dimensions.dart';
import '../../../../core/services/in_app_update_service.dart';

class AppUpdateScreen extends StatefulWidget {
  const AppUpdateScreen({
    super.key,
    required this.apkLink,
    required this.updateVersion,
    required this.currentVersion,
    required this.whatsNew,
  });

  final String apkLink;
  final String updateVersion;
  final String currentVersion;
  final String whatsNew;

  static Widget fromExtra(Map<String, dynamic>? extra) {
    final e = extra ?? {};
    return AppUpdateScreen(
      apkLink: e['apkLink'] as String? ?? '',
      updateVersion: e['updateVersion'] as String? ?? '',
      currentVersion: e['currentVersion'] as String? ?? '',
      whatsNew: e['whatsNew'] as String? ?? '',
    );
  }

  @override
  State<AppUpdateScreen> createState() => _AppUpdateScreenState();
}

class _AppUpdateScreenState extends State<AppUpdateScreen> {
  late final ScrollController _scrollController;
  bool _showBottomFade = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFade());
  }

  void _onScroll() => _checkFade();

  void _checkFade() {
    if (!_scrollController.hasClients) return;
    final atBottom = _scrollController.offset >= _scrollController.position.maxScrollExtent - 4;
    final hasOverflow = _scrollController.position.maxScrollExtent > 0;
    final shouldShow = hasOverflow && !atBottom;
    if (shouldShow != _showBottomFade) {
      setState(() => _showBottomFade = shouldShow);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apkLink = widget.apkLink;
    final updateVersion = widget.updateVersion;
    final currentVersion = widget.currentVersion;
    final whatsNew = widget.whatsNew;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final surfaceColor = colorScheme.surface;
    final contentBgColor = colorScheme.surfaceContainer;

    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Flat Corporate Header Area (replacing gradient and status bar headers)
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMarginXl),
              color: colorScheme.primary.withValues(alpha: 0.05),
              child: Center(
                child: SvgPicture.asset(
                  Assets.updateRocketIcon,
                  width: AppSizes.titleContainerHeight,
                  height: AppSizes.titleContainerHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Content Details Area
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppSizes.paddingMarginLg),
                color: contentBgColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'New Update Available',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceBtwTexts),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _VersionBadge(label: 'V $currentVersion', isCurrent: true),
                        const SizedBox(width: AppSizes.spaceBtwItems / 2),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: AppSizes.iconSm,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSizes.spaceBtwItems / 2),
                        _VersionBadge(label: 'V $updateVersion', isCurrent: false),
                      ],
                    ),
                    const SizedBox(height: AppSizes.defaultSpace),
                    
                    // What's New Section with corporate scroll fade
                    Expanded(
                      child: ShaderMask(
                        shaderCallback: (rect) {
                          return LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: _showBottomFade
                                ? [Colors.white, Colors.white, Colors.transparent]
                                : [Colors.white, Colors.white],
                            stops: _showBottomFade ? [0.0, 0.75, 1.0] : [0.0, 1.0],
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.dstIn,
                        child: SizedBox(
                          width: double.infinity,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: AppSizes.paddingMarginMd),
                              child: Text(
                                whatsNew.isNotEmpty
                                    ? whatsNew
                                    : 'The current version of the application is no longer supported. Update the app to use the latest features.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.5,
                                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.defaultSpace),

                    // Actions Area (Progress Indicator & Buttons)
                    ValueListenableBuilder<bool>(
                      valueListenable: InAppUpdateService.isDownloading,
                      builder: (context, isDownloading, _) {
                        if (isDownloading) {
                          return ValueListenableBuilder<String>(
                            valueListenable: InAppUpdateService.updateProgress,
                            builder: (context, prog, _) {
                              double pct = 0;
                              try {
                                pct = double.parse(prog.replaceAll('%', '')) / 100.0;
                              } catch (_) {
                                pct = 0;
                              }
                              return Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      minHeight: AppSizes.paddingMarginSm,
                                      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.spaceBtwTexts),
                                  Text(
                                    'Downloading update... $prog %',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: AppSizes.buttonHeightXl,
                              child: FilledButton(
                                onPressed: () => InAppUpdateService.downloadAndInstall(latestApkUrl: apkLink),
                                style: FilledButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                                  ),
                                ),
                                child: const Text(
                                  'Update Now',
                                  style: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSizes.spaceBtwButtons / 2),
                            TextButton(
                              onPressed: () {
                                context.pop();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: colorScheme.error,
                              ),
                              child: const Text("No, Thanks! Close the app"),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionBadge extends StatelessWidget {
  final String label;
  final bool isCurrent;

  const _VersionBadge({required this.label, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final badgeColor = isCurrent
        ? colorScheme.surfaceContainerHigh
        : colorScheme.primary.withValues(alpha: 0.1);
    final borderColor = isCurrent
        ? colorScheme.outlineVariant
        : colorScheme.primary;
    final textColor = isCurrent
        ? colorScheme.onSurfaceVariant
        : colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMarginSm + 2,
        vertical: AppSizes.paddingMarginXs,
      ),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        border: Border.all(
          color: borderColor,
          width: AppSizes.dividerThickness,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
