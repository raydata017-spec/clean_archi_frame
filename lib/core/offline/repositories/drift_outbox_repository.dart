import 'dart:convert';

import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../offline_outbox_item.dart';
import 'offline_outbox_repository.dart';
import '../../utils/enums/outbox_status_enum.dart';

class DriftOutboxRepository implements OfflineOutboxRepository {
  final AppDatabase _db;

  DriftOutboxRepository(this._db);

  @override
  Stream<List<OfflineOutboxItem>> watchOutbox() {
    return (_db.select(_db.outboxTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
          ]))
        .watch()
        .map((rows) => rows.map(_mapToItem).toList());
  }

  @override
  Future<int> enqueue(OutboxEnqueueParams params) {
    return _db.into(_db.outboxTable).insert(
          OutboxTableCompanion.insert(
            url: params.url,
            method: params.method,
            actionType: params.actionType,
            payload: jsonEncode(params.payload),
            clientReferenceId: Value(params.clientReferenceId),
            maxRetries: Value(params.maxRetries),
            status: Value(OutboxStatusEnum.pending.index),
          ),
        );
  }

  @override
  Future<OfflineOutboxItem?> getNextSyncableItem() async {
    final now = DateTime.now();
    final query = _db.select(_db.outboxTable)
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
      ..limit(1);

    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _mapToItem(row);
  }

  @override
  Future<DateTime?> getEarliestNextRetryAt() async {
    final now = DateTime.now();
    final query = _db.select(_db.outboxTable)
      ..where(
        (t) =>
            (t.status.equals(OutboxStatusEnum.pending.index) |
                t.status.equals(OutboxStatusEnum.failed.index)) &
            t.retryCount.isSmallerThan(t.maxRetries) &
            t.nextRetryAt.isBiggerThan(Variable(now)),
      )
      ..orderBy([
        (t) => OrderingTerm(expression: t.nextRetryAt, mode: OrderingMode.asc),
      ])
      ..limit(1);

    final row = await query.getSingleOrNull();
    return row?.nextRetryAt;
  }

  @override
  Future<int> resetStuckSyncingItems() {
    return (_db.update(_db.outboxTable)
          ..where((t) => t.status.equals(OutboxStatusEnum.syncing.index)))
        .write(
      OutboxTableCompanion(
        status: Value(OutboxStatusEnum.pending.index),
        nextRetryAt: const Value(null),
        updatedAt: Value(DateTime.now()),
        lastError: const Value('Recovered from stuck syncing state'),
      ),
    );
  }

  @override
  Future<void> updateOutboxItem({
    required int id,
    required OutboxStatusEnum status,
    required int retryCount,
    String? lastError,
    DateTime? nextRetryAt,
    bool clearNextRetryAt = false,
  }) async {
    await (_db.update(_db.outboxTable)..where((t) => t.id.equals(id))).write(
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

  @override
  Future<void> retryOutboxItem(int id) async {
    await _db.outboxDao.retryOutboxItem(id);
  }

  @override
  Future<void> deleteOutboxItem(int id) async {
    await (_db.delete(_db.outboxTable)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) {
    return _db.transaction(action);
  }

  OfflineOutboxItem _mapToItem(OutboxTableData data) {
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
      nextRetryAt: data.nextRetryAt,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}
