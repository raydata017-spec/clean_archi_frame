import '../utils/enums/outbox_status_enum.dart';
import 'offline_outbox_item.dart';

abstract class OfflineOutboxRepository {
  /// Watches the outbox items (notifies whenever items change or are added).
  Stream<List<OfflineOutboxItem>> watchOutbox();

  /// Gets the next syncable item in FIFO order.
  /// A syncable item is one that is 'pending' or 'failed' and has remaining retries.
  Future<OfflineOutboxItem?> getNextSyncableItem();

  /// Updates status and retry counts of an outbox item.
  Future<void> updateOutboxItem({required int id, required OutboxStatusEnum status, required int retryCount, String? lastError});

  /// Deletes an outbox item from the queue.
  Future<void> deleteOutboxItem(int id);
}
