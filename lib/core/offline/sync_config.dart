class SyncConfig {
  final int maxRetries; // Maximum number of retries before marking an outbox item as failed
  final Duration cleanupDuration; // How long to keep synced local database records (e.g., 7 days) before auto-cleaning
  final bool wifiOnly; // When true, sync will only execute if connected to Wi-Fi

  const SyncConfig({
    this.maxRetries = 3,
    this.cleanupDuration = const Duration(days: 7),
    this.wifiOnly = false,
  });
}
