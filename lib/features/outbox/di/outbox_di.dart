import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clean_archi_frame/core/di/database_di.dart';
import 'package:clean_archi_frame/core/offline/offline_outbox_repository.dart';
import 'package:clean_archi_frame/features/outbox/data/repositories/drift_outbox_repository.dart';

/// Provider for OfflineOutboxRepository implementation using Drift database.
final offlineOutboxRepositoryProvider = Provider<OfflineOutboxRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftOutboxRepository(database);
});
