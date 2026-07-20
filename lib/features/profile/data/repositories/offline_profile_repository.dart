import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/offline/offline_outbox_item.dart';
import '../../../../core/offline/repositories/offline_outbox_repository.dart';
import '../data_sources/local/dao/profile_dao.dart';

/// Result of an offline profile create.
class OfflineProfileCreateResult {
  final int localId;
  final int outboxId;
  final String clientReferenceId;

  const OfflineProfileCreateResult({
    required this.localId,
    required this.outboxId,
    required this.clientReferenceId,
  });
}

/// End-to-end sample: optimistic local write + outbox enqueue.
///
/// Pattern for other features:
/// 1. Write to local Drift table
/// 2. Enqueue outbox item (same transaction)
/// 3. Let [OfflineSyncEngine] + processor sync when online
class OfflineProfileRepository {
  final ProfileDao _profileDao;
  final OfflineOutboxRepository _outboxRepository;

  OfflineProfileRepository({
    required ProfileDao profileDao,
    required OfflineOutboxRepository outboxRepository,
  })  : _profileDao = profileDao,
        _outboxRepository = outboxRepository;

  /// Creates a profile locally and queues a `create_profile` sync action.
  Future<OfflineProfileCreateResult> createOffline({
    required String name,
    required String email,
    String? avatarUrl,
  }) {
    return _outboxRepository.runInTransaction(() async {
      final localId = await _profileDao.insertProfile(
        ProfileTableCompanion.insert(
          name: name,
          email: email,
          avatarUrl: Value(avatarUrl),
        ),
      );

      final clientReferenceId = 'profile_$localId';
      final outboxId = await _outboxRepository.enqueue(
        OutboxEnqueueParams(
          url: '/api/profiles',
          method: 'POST',
          actionType: 'create_profile',
          clientReferenceId: clientReferenceId,
          payload: {
            'localId': localId,
            'name': name,
            'email': email,
            if (avatarUrl != null) 'avatarUrl': avatarUrl,
          },
        ),
      );

      return OfflineProfileCreateResult(
        localId: localId,
        outboxId: outboxId,
        clientReferenceId: clientReferenceId,
      );
    });
  }

  /// Updates a profile locally and queues an `update_profile` sync action.
  Future<int> updateOffline({
    required int localId,
    required String name,
    required String email,
    String? avatarUrl,
    String? serverId,
  }) {
    return _outboxRepository.runInTransaction(() async {
      await _profileDao.updateProfile(
        localId,
        ProfileTableCompanion(
          name: Value(name),
          email: Value(email),
          avatarUrl: Value(avatarUrl),
        ),
      );

      return _outboxRepository.enqueue(
        OutboxEnqueueParams(
          url: '/api/profiles/$localId',
          method: 'PUT',
          actionType: 'update_profile',
          clientReferenceId: 'profile_$localId',
          payload: {
            'localId': localId,
            if (serverId != null) 'id': serverId,
            'name': name,
            'email': email,
            if (avatarUrl != null) 'avatarUrl': avatarUrl,
          },
        ),
      );
    });
  }
}
