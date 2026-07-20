import 'package:drift/drift.dart';

/// Maps offline client-generated IDs to server IDs after a successful sync.
class ReferenceMappingTable extends Table {
  TextColumn get clientId => text()();
  TextColumn get serverId => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {clientId};
}
