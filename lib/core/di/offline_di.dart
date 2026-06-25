import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/outbox/di/outbox_di.dart';
import '../offline/local_reference_repository.dart';
import '../offline/offline_sync_engine.dart';

/// Provider for OfflineSyncEngine singleton instance.
final offlineSyncEngineProvider = Provider<OfflineSyncEngine>((ref) {
  final outboxRepo = ref.watch(offlineOutboxRepositoryProvider);
  
  final engine = OfflineSyncEngine(
    outboxRepository: outboxRepo,
    referenceRepository: _MockReferenceRepository(),
  );

  ref.onDispose(() {
    engine.dispose();
  });

  return engine;
});

class _MockReferenceRepository extends LocalReferenceRepository {
  @override
  Future<void> clearAllMappings() async {}

  @override
  Future<String?> getServerId(String clientId) async => null;

  @override
  Future<void> saveMapping({required String clientId, required String serverId}) async {}
}
