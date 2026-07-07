import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/router_redirect_config.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/notification/presentation/screens/notification_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/setting/presentation/screens/setting_screen.dart';
import '../../core/offline/screens/outbox_list_screen.dart';
import '../../shared/main_wrapper_screen.dart';
import '../../core/utils/enums/app_auth_state_enum.dart';
import 'navigator_keys.dart';
import 'route_names.dart';

/// Fallback providers for routing state.
/// Override these or adapt their logic to target project auth providers.
final appAuthStateProvider = Provider<AsyncValue<AppAuthState>>((ref) {
  return const AsyncValue.data(AppAuthState.authenticatedWithBranch);
});

final appInitializedStateProvider = Provider<bool>((ref) {
  return true;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: NavigatorKeys.root,
    initialLocation: RouteNames.homePath,
    redirect: (context, state) {
      if (!RouterRedirectConfig.enableRedirect) return null;

      final authStateAsync = ref.read(appAuthStateProvider);
      final matchedLocation = state.matchedLocation;

      final isGoingToLogin = matchedLocation == RouterRedirectConfig.loginPath;
      final isGoingToSplash = matchedLocation == RouterRedirectConfig.splashPath;
      final isGoingToSelectBranch =
          matchedLocation == RouterRedirectConfig.selectBranchPath;

      return authStateAsync.when(
        data: (authState) {
          final isInitialized = ref.read(appInitializedStateProvider);

          switch (authState) {
            case AppAuthState.unauthenticated:
              if (!isGoingToLogin) {
                return RouterRedirectConfig.loginPath;
              }
              break;

            case AppAuthState.authenticatedNoBranch:
              if (RouterRedirectConfig.enableBranchSelection) {
                if (RouterRedirectConfig.enableSplash && !isInitialized && isGoingToSplash) {
                  return null;
                }
                if (isGoingToLogin ||
                    (RouterRedirectConfig.enableSplash && isGoingToSplash) ||
                    matchedLocation == RouterRedirectConfig.homePath) {
                  return RouterRedirectConfig.selectBranchPath;
                }
              }
              break;

            case AppAuthState.authenticatedWithBranch:
              if (RouterRedirectConfig.enableSplash && !isInitialized && isGoingToSplash) {
                return null;
              }
              if (isGoingToLogin ||
                  (RouterRedirectConfig.enableSplash && isGoingToSplash) ||
                  (RouterRedirectConfig.enableBranchSelection && isGoingToSelectBranch)) {
                return RouterRedirectConfig.homePath;
              }
              break;
          }
          return null;
        },
        loading: () => RouterRedirectConfig.enableSplash
            ? RouterRedirectConfig.splashPath
            : RouterRedirectConfig.loginPath,
        error: (_, __) => RouterRedirectConfig.loginPath,
      );
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapperScreen(navigationShell: navigationShell);
        },
        branches: [
          // --- Branch 1: Home ---
          StatefulShellBranch(
            navigatorKey: NavigatorKeys.shellHome,
            routes: [
              GoRoute(
                path: RouteNames.homePath,
                name: RouteNames.homeName,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // --- Branch 2: Profile ---
          StatefulShellBranch(
            navigatorKey: NavigatorKeys.shellProfile,
            routes: [
              GoRoute(
                path: RouteNames.profilePath,
                name: RouteNames.profileName,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),

          // --- Branch 3: Settings ---
          StatefulShellBranch(
            navigatorKey: NavigatorKeys.shellSettings,
            routes: [
              GoRoute(
                path: RouteNames.settingsPath,
                name: RouteNames.settingsName,
                builder: (context, state) => const SettingScreen(),
                routes: [
                  GoRoute(
                    path: RouteNames.outboxPath,
                    name: RouteNames.outboxName,
                    builder: (context, state) => const OutboxListScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // --- Auth Routes (outside shell) ---
      GoRoute(
        path: RouteNames.loginPath,
        name: RouteNames.loginName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.registerPath,
        name: RouteNames.registerName,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Notification Route
      GoRoute(
        path: RouteNames.notificationPath,
        name: RouteNames.notificationName,
        builder: (context, state) => const NotificationScreen(),
      ),
    ],
  );
});
