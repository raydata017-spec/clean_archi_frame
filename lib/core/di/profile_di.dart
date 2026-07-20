import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/profile/data/data_sources/local/dao/profile_dao.dart';
import '../../features/profile/data/data_sources/processors/update_profile_processor.dart';
import '../../features/profile/data/repositories/offline_profile_repository.dart';
import '../offline/offline_sync_engine.dart';
import 'database_di.dart';
import 'offline_di.dart';
import 'outbox_di.dart';

/// Provider for ProfileDao to access profile table queries.
final profileDaoProvider = Provider<ProfileDao>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return ProfileDao(database);
});

/// Stream provider for profile table rows.
final profileListProvider = StreamProvider.autoDispose((ref) {
  return ref.watch(profileDaoProvider).watchProfiles();
});

/// End-to-end offline sample repository (local write + outbox enqueue).
final offlineProfileRepositoryProvider =
    Provider<OfflineProfileRepository>((ref) {
  return OfflineProfileRepository(
    profileDao: ref.watch(profileDaoProvider),
    outboxRepository: ref.watch(offlineOutboxRepositoryProvider),
  );
});

/// Registers profile outbox processors on the sync engine.
///
/// Watch this once at app startup (e.g. in [MyApp]) so processors are ready
/// before any offline writes are synced.
final profileOfflineBootstrapProvider = Provider<OfflineSyncEngine>((ref) {
  final engine = ref.watch(offlineSyncEngineProvider);
  engine.registerProcessor(CreateProfileProcessor());
  engine.registerProcessor(UpdateProfileProcessor());
  return engine;
});
