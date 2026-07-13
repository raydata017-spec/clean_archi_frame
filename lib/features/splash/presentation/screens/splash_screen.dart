import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/dimensions.dart';
import '../../../../app/config/splash_config.dart';

/// Global Riverpod Provider for Splash Configuration.
final splashConfigProvider = Provider<SplashConfig>((ref) {
  return SplashConfig.current;
});

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startInitializationFlow();
  }

  Future<void> _startInitializationFlow() async {
    final config = ref.read(splashConfigProvider);
    final stopwatch = Stopwatch()..start();

    // 1. Run custom background initialization task if specified
    if (config.onInitialize != null && mounted) {
      try {
        await config.onInitialize!(context);
      } catch (e) {
        debugPrint('Error during splash onInitialize: $e');
      }
    }

    // 2. Ensure splash stays visible for at least minDuration
    stopwatch.stop();
    final elapsed = stopwatch.elapsed;
    if (elapsed < config.minDuration) {
      final remaining = config.minDuration - elapsed;
      await Future.delayed(remaining);
    }

    // 3. Navigate to the next route config
    if (mounted) {
      context.go(config.nextRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(splashConfigProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Corporate Flat Style Design setup (no gradient, solid background)
    final backgroundColor = config.backgroundColor ?? colorScheme.surface;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMarginLg),
          child: Stack(
            children: [
              // Logo and brand display in the center
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (config.logoWidget != null)
                      config.logoWidget!
                    else if (config.logoPath != null)
                      _buildLogoFromPath(config.logoPath!)
                    else
                      // Default Minimalist Icon Placeholder
                      Icon(
                        Icons.widgets_outlined,
                        size: AppSizes.imageThumbSize,
                        color: colorScheme.primary,
                      ),
                    const SizedBox(height: AppSizes.spaceBtwSections),

                    // Loading indicator layout complying with corporate minimal sizes
                    config.loadingIndicator ??
                        SizedBox(
                          width: AppSizes.iconLg,
                          height: AppSizes.iconLg,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                          ),
                        ),
                  ],
                ),
              ),

              // Version display at the bottom center
              if (config.versionText != null)
                Positioned(
                  bottom: AppSizes.paddingFromScreenEdge,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      config.versionText!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoFromPath(String path) {
    if (path.endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: AppSizes.imageThumbSize,
        height: AppSizes.imageThumbSize,
      );
    } else {
      return Image.asset(
        path,
        width: AppSizes.imageThumbSize,
        height: AppSizes.imageThumbSize,
      );
    }
  }
}
