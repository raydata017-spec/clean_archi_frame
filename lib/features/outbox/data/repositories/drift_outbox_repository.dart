import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/offline/offline_outbox_item.dart';
import '../../../../core/offline/offline_outbox_repository.dart';
import '../../../../core/utils/enums/outbox_status_enum.dart';

class DriftOutboxRepository implements OfflineOutboxRepository {
  final AppDatabase _db;

  DriftOutboxRepository(this._db);

  @override
  Stream<List<OfflineOutboxItem>> watchOutbox() {
    return (_db.select(_db.outboxTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)
          ]))
        .watch()
        .map((rows) => rows.map(_mapToItem).toList());
  }

  @override
  Future<OfflineOutboxItem?> getNextSyncableItem() async {
    final query = _db.select(_db.outboxTable)
      ..where((t) => t.status.equals(OutboxStatusEnum.pending.index) | t.status.equals(OutboxStatusEnum.failed.index))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)])
      ..limit(1);

    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _mapToItem(row);
  }

  @override
  Future<void> updateOutboxItem({
    required int id,
    required OutboxStatusEnum status,
    required int retryCount,
    String? lastError,
  }) async {
    await (_db.update(_db.outboxTable)..where((t) => t.id.equals(id))).write(
      OutboxTableCompanion(
        status: Value(status.index),
        retryCount: Value(retryCount),
        lastError: Value(lastError),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteOutboxItem(int id) async {
    await (_db.delete(_db.outboxTable)..where((t) => t.id.equals(id))).go();
  }

  OfflineOutboxItem _mapToItem(OutboxTableData data) {
    // Determine the status from int index
    final status = data.status >= 0 && data.status < OutboxStatusEnum.values.length
        ? OutboxStatusEnum.values[data.status]
        : OutboxStatusEnum.unknow;

    return OfflineOutboxItem(
      id: data.id,
      url: data.url,
      method: data.method,
      actionType: data.actionType,
      payload: data.payload,
      retryCount: data.retryCount,
      clientReferenceId: data.clientReferenceId,
      maxRetries: data.maxRetries,
      status: status,
      lastError: data.lastError,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}
