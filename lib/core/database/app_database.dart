import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../offline/schema/outbox_table.dart' show OutboxTable;
import '../offline/schema/reference_mapping_table.dart' show ReferenceMappingTable;
import '../../features/profile/data/data_sources/local/schema/profiles_schema.dart';
import '../../features/profile/data/data_sources/local/dao/profile_dao.dart';
import '../offline/dao/outbox_dao.dart';
import '../offline/dao/reference_mapping_dao.dart';
import '../utils/enums/outbox_status_enum.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [ProfileTable, OutboxTable, ReferenceMappingTable],
  daos: [ProfileDao, OutboxDao, ReferenceMappingDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// In-memory / custom executor for unit tests.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(outboxTable, outboxTable.nextRetryAt);
            await m.createTable(referenceMappingTable);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(
    () async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'app_database.sqlite'));

      return NativeDatabase.createInBackground(
        file,
        setup: (db) {
          db.execute('PRAGMA journal_mode=WAL;');
        },
      );
    },
  );
}
