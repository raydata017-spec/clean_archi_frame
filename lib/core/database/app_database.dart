import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../offline/schema/outbox_table.dart' show OutboxTable;
import '../../features/profile/data/data_sources/local/schema/profiles_schema.dart';
import '../utils/enums/outbox_status_enum.dart';
import '../../features/profile/data/data_sources/local/dao/profile_dao.dart';
import '../offline/dao/outbox_dao.dart';

part 'app_database.g.dart';

// Drift Database, tables and daos
@DriftDatabase(
  tables: [ProfileTable, OutboxTable],
  daos: [ProfileDao, OutboxDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

// Open Database
LazyDatabase _openConnection() {
  return LazyDatabase(
    () async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'app_database.sqlite'));

      return NativeDatabase.createInBackground(
        file,
        setup: (db) {
          // 💡 Background Isolate နှင့် Foreground UI ပြိုင်တူသုံးနိုင်ရန်
          db.execute('PRAGMA journal_mode=WAL;');
        },
      );
    },
  );
}
