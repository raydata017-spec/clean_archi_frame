import 'offline_outbox_item.dart';
import 'repositories/offline_outbox_repository.dart';

/// Helper for the standard offline write pattern:
/// 1) mutate local Drift tables
/// 2) enqueue an outbox item
/// — both inside a single transaction.
class OfflineWriteCoordinator {
  final OfflineOutboxRepository _outboxRepository;

  OfflineWriteCoordinator(this._outboxRepository);

  /// Runs [localWrite] then enqueues [params] atomically.
  /// Returns the new outbox row id.
  Future<int> writeLocalThenEnqueue({
    required Future<void> Function() localWrite,
    required OutboxEnqueueParams params,
  }) {
    return _outboxRepository.runInTransaction(() async {
      await localWrite();
      return _outboxRepository.enqueue(params);
    });
  }

  /// Enqueue only (when local write already happened or is not needed).
  Future<int> enqueue(OutboxEnqueueParams params) {
    return _outboxRepository.enqueue(params);
  }
}
