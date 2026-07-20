import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/profile/data/data_sources/processors/update_profile_processor.dart';
import '../offline/offline_sync_engine.dart';
import '../offline/offline_write_coordinator.dart';
import '../offline/outbox_action_processor.dart';
import '../offline/sync_config.dart';
import '../services/connectivity_service.dart';
import 'outbox_di.dart';

import '../offline/dao/reference_mapping_dao.dart';
import '../offline/repositories/drift_local_reference_repository.dart';
import '../offline/repositories/local_reference_repository.dart';
import 'database_di.dart';

final referenceMappingDaoProvider = Provider<ReferenceMappingDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ReferenceMappingDao(db);
});

/// Useful for cross-action references that must be rewritten before dependent outbox sync.
final localReferenceRepositoryProvider = Provider<LocalReferenceRepository>((ref) {
  final dao = ref.watch(referenceMappingDaoProvider);
  return DriftLocalReferenceRepository(dao);
});

final offlineWriteCoordinatorProvider = Provider<OfflineWriteCoordinator>((ref) {
  final outboxRepo = ref.watch(offlineOutboxRepositoryProvider);
  return OfflineWriteCoordinator(outboxRepo);
});

/// Registry provider for all feature OutboxActionProcessors across the app.
final outboxProcessorsProvider = Provider<List<OutboxActionProcessor>>((ref) {
  return [
    ref.watch(updateProfileProcessorProvider),
  ];
});

/// Singleton OfflineSyncEngine. Callers should `await engine.initialize()`.
final offlineSyncEngineProvider = Provider<OfflineSyncEngine>((ref) {
  final outboxRepo = ref.watch(offlineOutboxRepositoryProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  final processors = ref.watch(outboxProcessorsProvider);

  final engine = OfflineSyncEngine(
    outboxRepository: outboxRepo,
    connectivity: connectivity,
    config: const SyncConfig(),
  );

  for (final processor in processors) {
    engine.registerProcessor(processor);
  }

  // Fire-and-forget init: recover stuck items + start listeners.
  engine.initialize();

  ref.onDispose(() {
    engine.dispose();
  });

  return engine;
});
