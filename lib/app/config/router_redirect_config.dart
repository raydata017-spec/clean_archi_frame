import '../router/route_names.dart';

/// Router configuration for redirects.
/// Customize these values in the target project without touching main.dart.
class RouterRedirectConfig {
  static const bool enableRedirect = false; // Set to true to enable redirect logic
  static const bool enableBranchSelection = false;
  static const bool enableSplash = false;

  static const String splashPath = '/splash';
  static const String selectBranchPath = '/select-branch';
  static const String loginPath = RouteNames.loginPath;
  static const String homePath = RouteNames.homePath;
}
