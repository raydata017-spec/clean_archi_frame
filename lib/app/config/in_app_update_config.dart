class InAppUpdateConfig {
  /// Firebase Remote Config key to fetch the APK URL.
  final String remoteApkLinkKey;

  /// Firebase Remote Config key to fetch the remote app version.
  final String remoteVersionKey;

  /// Firebase Remote Config key to fetch the release notes / what's new description.
  final String remoteWhatsNewKey;

  /// The local filename when downloading the update APK on Android.
  final String destinationFilename;

  /// Android Provider Authority for installing the APK using standard `ota_update`.
  final String androidProviderAuthority;

  /// Maximum duration to wait for remote configuration fetch.
  final Duration fetchTimeout;

  /// Minimum interval to check remote configuration before refetching.
  final Duration minimumFetchInterval;

  const InAppUpdateConfig({
    this.remoteApkLinkKey = 'mobile_apk_link',
    this.remoteVersionKey = 'mobile_app_version',
    this.remoteWhatsNewKey = 'mobile_whats_new',
    this.destinationFilename = 'app_update.apk',
    this.androidProviderAuthority = 'com.example.app.ota_update_provider',
    this.fetchTimeout = const Duration(seconds: 10),
    this.minimumFetchInterval = const Duration(hours: 1),
  });

  /// Centralized static instance for current project updates config values.
  /// Modify this const variable to customize in-app updates for target projects.
  static const InAppUpdateConfig current = InAppUpdateConfig(
    remoteApkLinkKey: 'mobile_apk_link',
    remoteVersionKey: 'mobile_app_version',
    remoteWhatsNewKey: 'mobile_whats_new',
    destinationFilename: 'app_update.apk',
    androidProviderAuthority: 'com.example.app.ota_update_provider',
    fetchTimeout: Duration(seconds: 10),
    minimumFetchInterval: Duration(hours: 1),
  );
}
