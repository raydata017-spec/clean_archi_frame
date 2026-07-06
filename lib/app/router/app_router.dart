import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/notification/presentation/screens/notification_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/setting/presentation/screens/setting_screen.dart';
import '../../core/offline/screens/outbox_list_screen.dart';
import '../../shared/main_wrapper_screen.dart';
import 'navigator_keys.dart';
import 'route_names.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: NavigatorKeys.root,
    initialLocation: RouteNames.homePath,
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
