import '../../utils/enums/outbox_status_enum.dart';
import '../offline_outbox_item.dart';

abstract class OfflineOutboxRepository {
  /// Watches the outbox items (notifies whenever items change or are added).
  Stream<List<OfflineOutboxItem>> watchOutbox();

  /// Enqueues a new write action into the outbox (status = pending).
  /// Returns the inserted row id.
  Future<int> enqueue(OutboxEnqueueParams params);

  /// Gets the next syncable item in FIFO order.
  /// Syncable = pending/failed, has remaining retries, and nextRetryAt has passed.
  Future<OfflineOutboxItem?> getNextSyncableItem();

  /// Returns the soonest future [nextRetryAt] among retryable failed items, if any.
  Future<DateTime?> getEarliestNextRetryAt();

  /// Resets items stuck in `syncing` (e.g. after an app crash) back to pending.
  Future<int> resetStuckSyncingItems();

  /// Updates status and retry counts of an outbox item.
  Future<void> updateOutboxItem({
    required int id,
    required OutboxStatusEnum status,
    required int retryCount,
    String? lastError,
    DateTime? nextRetryAt,
    bool clearNextRetryAt = false,
  });

  /// Deletes an outbox item from the queue.
  Future<void> deleteOutboxItem(int id);

  /// Runs [action] inside a database transaction (for local write + enqueue).
  Future<T> runInTransaction<T>(Future<T> Function() action);
}
