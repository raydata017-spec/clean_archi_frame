import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_di.dart';
import 'outbox_di.dart';
import '../offline/dao/reference_mapping_dao.dart';
import '../offline/offline_sync_engine.dart';
import '../offline/offline_write_coordinator.dart';
import '../offline/repositories/drift_local_reference_repository.dart';
import '../offline/repositories/local_reference_repository.dart';
import '../offline/sync_config.dart';
import '../services/connectivity_service.dart';

final referenceMappingDaoProvider = Provider<ReferenceMappingDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ReferenceMappingDao(db);
});

final localReferenceRepositoryProvider =
    Provider<LocalReferenceRepository>((ref) {
  final dao = ref.watch(referenceMappingDaoProvider);
  return DriftLocalReferenceRepository(dao);
});

final offlineWriteCoordinatorProvider =
    Provider<OfflineWriteCoordinator>((ref) {
  final outboxRepo = ref.watch(offlineOutboxRepositoryProvider);
  return OfflineWriteCoordinator(outboxRepo);
});

/// Singleton OfflineSyncEngine. Callers should `await engine.initialize()`.
final offlineSyncEngineProvider = Provider<OfflineSyncEngine>((ref) {
  final outboxRepo = ref.watch(offlineOutboxRepositoryProvider);
  final referenceRepo = ref.watch(localReferenceRepositoryProvider);
  final connectivity = ref.watch(connectivityServiceProvider);

  final engine = OfflineSyncEngine(
    outboxRepository: outboxRepo,
    referenceRepository: referenceRepo,
    connectivity: connectivity,
    config: const SyncConfig(),
  );

  // Fire-and-forget init: recover stuck items + start listeners.
  engine.initialize();

  ref.onDispose(() {
    engine.dispose();
  });

  return engine;
});
