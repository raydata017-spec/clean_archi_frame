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

  Future<OutboxTableData?> getNextSyncableItem() {
    return (select(outboxTable)
          ..where((t) => t.status.equals(OutboxStatusEnum.pending.index) | t.status.equals(OutboxStatusEnum.failed.index))
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> updateOutboxStatus({
    required int id,
    required OutboxStatusEnum status,
    required int retryCount,
    String? lastError,
  }) {
    return (update(outboxTable)..where((t) => t.id.equals(id))).write(
      OutboxTableCompanion(
        status: Value(status.index),
        retryCount: Value(retryCount),
        lastError: Value(lastError),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteOutboxItem(int id) {
    return (delete(outboxTable)..where((t) => t.id.equals(id))).go();
  }
}
