import 'package:drift/drift.dart';

import '../../utils/enums/outbox_status_enum.dart' show OutboxStatusEnum;


class OutboxTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get url => text()();
  TextColumn get method => text().withLength(min: 3, max: 10)();
  TextColumn get actionType => text()();
  TextColumn get payload => text()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get clientReferenceId => text().nullable()();
  IntColumn get maxRetries => integer().withDefault(const Constant(3))();
  IntColumn get status =>
      integer().withDefault(Constant(OutboxStatusEnum.pending.index))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
