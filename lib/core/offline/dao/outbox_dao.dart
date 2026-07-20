import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../schema/outbox_table.dart';
import '../../utils/enums/outbox_status_enum.dart';

part 'outbox_dao.g.dart';

@DriftAccessor(tables: [OutboxTable])
class OutboxDao extends DatabaseAccessor<AppDatabase> with _$OutboxDaoMixin {
  OutboxDao(super.db);

  Stream<List<OutboxTableData>> watchOutbox() {
    return (select(outboxTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  Future<int> enqueue({
    required String url,
    required String method,
    required String actionType,
    required String payload,
    String? clientReferenceId,
    int maxRetries = 3,
  }) {
    return into(outboxTable).insert(
      OutboxTableCompanion.insert(
        url: url,
        method: method,
        actionType: actionType,
        payload: payload,
        clientReferenceId: Value(clientReferenceId),
        maxRetries: Value(maxRetries),
        status: Value(OutboxStatusEnum.pending.index),
      ),
    );
  }

  Future<OutboxTableData?> getNextSyncableItem() {
    final now = DateTime.now();
    return (select(outboxTable)
          ..where(
            (t) =>
                (t.status.equals(OutboxStatusEnum.pending.index) |
                    t.status.equals(OutboxStatusEnum.failed.index)) &
                t.retryCount.isSmallerThan(t.maxRetries) &
                (t.nextRetryAt.isNull() | t.nextRetryAt.isSmallerOrEqual(Variable(now))),
          )
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> resetStuckSyncingItems() {
    return (update(outboxTable)..where((t) => t.status.equals(OutboxStatusEnum.syncing.index)))
        .write(
      OutboxTableCompanion(
        status: Value(OutboxStatusEnum.pending.index),
        nextRetryAt: const Value(null),
        updatedAt: Value(DateTime.now()),
        lastError: const Value('Recovered from stuck syncing state'),
      ),
    );
  }

  Future<int> updateOutboxStatus({
    required int id,
    required OutboxStatusEnum status,
    required int retryCount,
    String? lastError,
    DateTime? nextRetryAt,
    bool clearNextRetryAt = false,
  }) {
    return (update(outboxTable)..where((t) => t.id.equals(id))).write(
      OutboxTableCompanion(
        status: Value(status.index),
        retryCount: Value(retryCount),
        lastError: Value(lastError),
        nextRetryAt: clearNextRetryAt
            ? const Value(null)
            : (nextRetryAt != null ? Value(nextRetryAt) : const Value.absent()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> retryOutboxItem(int id) {
    return (update(outboxTable)..where((t) => t.id.equals(id))).write(
      OutboxTableCompanion(
        status: Value(OutboxStatusEnum.pending.index),
        retryCount: const Value(0),
        nextRetryAt: const Value(null),
        lastError: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteOutboxItem(int id) {
    return (delete(outboxTable)..where((t) => t.id.equals(id))).go();
  }
}
