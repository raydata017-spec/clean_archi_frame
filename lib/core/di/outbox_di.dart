import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../offline/dao/outbox_dao.dart';
import '../offline/repositories/drift_outbox_repository.dart';
import '../offline/repositories/offline_outbox_repository.dart';
import 'database_di.dart';

/// Provider for OfflineOutboxRepository implementation using Drift database.
final offlineOutboxRepositoryProvider = Provider<OfflineOutboxRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftOutboxRepository(database);
});

/// Provider for OutboxDao to access outbox table queries.
final outboxDaoProvider = Provider<OutboxDao>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return OutboxDao(database);
});

/// Stream provider for outbox table rows.
final outboxListProvider = StreamProvider.autoDispose((ref) {
  return ref.watch(outboxDaoProvider).watchOutbox();
});
