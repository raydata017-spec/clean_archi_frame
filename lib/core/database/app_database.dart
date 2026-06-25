import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../features/outbox/data/local/schema/outbox_table.dart' show OutboxTable;
import '../../features/profile/data/local/schema/profiles_schema.dart';
import '../utils/enums/outbox_status_enum.dart';

part 'app_database.g.dart';

// Database, table and DAO declaration
@DriftDatabase(tables: [ProfileTable, OutboxTable], daos: [])

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