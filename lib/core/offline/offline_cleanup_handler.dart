abstract class OfflineCleanupHandler {
  /// Cleans up old synced data in local tables based on a [retentionDuration].
  /// Records older than [retentionDuration] from now will be deleted.
  Future<void> cleanup(Duration retentionDuration);
}
