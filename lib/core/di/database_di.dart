import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
/// Provider for Drift AppDatabase singleton instance.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() {
    db.close();
  });
  return db;
});
