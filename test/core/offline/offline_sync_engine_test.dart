import 'dart:async';

import 'package:clean_archi_frame/core/database/app_database.dart';
import 'package:clean_archi_frame/core/offline/offline_sync_engine.dart';
import 'package:clean_archi_frame/core/offline/repositories/drift_local_reference_repository.dart';
import 'package:clean_archi_frame/core/offline/repositories/drift_outbox_repository.dart';
import 'package:clean_archi_frame/core/offline/offline_outbox_item.dart';
import 'package:clean_archi_frame/core/services/connectivity_service.dart';
import 'package:clean_archi_frame/core/utils/enums/outbox_status_enum.dart';
import 'package:clean_archi_frame/core/utils/exceptions/sync_exceptions.dart';
import 'package:clean_archi_frame/core/offline/outbox_action_processor.dart';
import 'package:clean_archi_frame/core/offline/offline_outbox_item.dart';
import 'package:clean_archi_frame/core/utils/exceptions/sync_exceptions.dart';
import 'package:clean_archi_frame/features/profile/data/data_sources/processors/update_profile_processor.dart';
import 'package:clean_archi_frame/features/profile/data/repositories/offline_profile_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeConnectivity implements ConnectivityChecker {
  bool online;
  final _controller = StreamController<bool>.broadcast();

  FakeConnectivity({this.online = true});

  @override
  Future<bool> hasInternet() async => online;

  @override
  Stream<bool> get onStatusChanged => _controller.stream;

  void setOnline(bool value) {
    online = value;
    _controller.add(value);
  }

  @override
  void dispose() {
    _controller.close();
  }
}

/// Test helper processor that can throw controlled sync exceptions.
class ControllableProcessor extends OutboxActionProcessor {
  @override
  final String actionType;

  int callCount = 0;
  Object? Function(OfflineOutboxItem item)? behavior;
  Map<String, dynamic>? Function(OfflineOutboxItem item)? successResponse;

  ControllableProcessor({
    required this.actionType,
    this.behavior,
    this.successResponse,
  });

  @override
  Future<Map<String, dynamic>?> process(OfflineOutboxItem item) async {
    callCount++;
    final error = behavior?.call(item);
    if (error != null) {
      if (error is Exception) throw error;
      if (error is Error) throw error;
      throw SyncUnknownException(error.toString());
    }
    return successResponse?.call(item) ?? {'id': 'server_${item.id}'};
  }

  @override
  Future<void> onConflict(Object error, OfflineOutboxItem item) async {}

  @override
  Future<void> onFailure(
    Object error,
    OfflineOutboxItem item,
    int currentRetries,
  ) async {}
}

void main() {
  late AppDatabase db;
  late DriftOutboxRepository outbox;
  late DriftLocalReferenceRepository references;
  late FakeConnectivity connectivity;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    outbox = DriftOutboxRepository(db);
    references = DriftLocalReferenceRepository.fromDatabase(db);
    connectivity = FakeConnectivity(online: true);
  });

  tearDown(() async {
    connectivity.dispose();
    await db.close();
  });

  group('Outbox repository', () {
    test('enqueue + FIFO order', () async {
      final first = await outbox.enqueue(
        const OutboxEnqueueParams(
          url: '/a',
          method: 'POST',
          actionType: 'create_profile',
          payload: {'n': 1},
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 5));
      final second = await outbox.enqueue(
        const OutboxEnqueueParams(
          url: '/b',
          method: 'POST',
          actionType: 'create_profile',
          payload: {'n': 2},
        ),
      );

      expect(first, lessThan(second));

      final next = await outbox.getNextSyncableItem();
      expect(next?.id, first);
      expect(next?.payloadAsMap['n'], 1);
    });

    test('respects nextRetryAt backoff window', () async {
      final id = await outbox.enqueue(
        const OutboxEnqueueParams(
          url: '/a',
          method: 'POST',
          actionType: 'create_profile',
          payload: {'n': 1},
          maxRetries: 3,
        ),
      );

      await outbox.updateOutboxItem(
        id: id,
        status: OutboxStatusEnum.failed,
        retryCount: 1,
        nextRetryAt: DateTime.now().add(const Duration(hours: 1)),
        lastError: 'network',
      );

      expect(await outbox.getNextSyncableItem(), isNull);

      await outbox.updateOutboxItem(
        id: id,
        status: OutboxStatusEnum.failed,
        retryCount: 1,
        nextRetryAt: DateTime.now().subtract(const Duration(seconds: 1)),
      );

      expect((await outbox.getNextSyncableItem())?.id, id);
    });

    test('excludes exhausted retries', () async {
      final id = await outbox.enqueue(
        const OutboxEnqueueParams(
          url: '/a',
          method: 'POST',
          actionType: 'create_profile',
          payload: {'n': 1},
          maxRetries: 2,
        ),
      );

      await outbox.updateOutboxItem(
        id: id,
        status: OutboxStatusEnum.failed,
        retryCount: 2,
        clearNextRetryAt: true,
      );

      expect(await outbox.getNextSyncableItem(), isNull);
    });

    test('resetStuckSyncingItems recovers crash state', () async {
      final id = await outbox.enqueue(
        const OutboxEnqueueParams(
          url: '/a',
          method: 'POST',
          actionType: 'create_profile',
          payload: {'n': 1},
        ),
      );

      await outbox.updateOutboxItem(
        id: id,
        status: OutboxStatusEnum.syncing,
        retryCount: 0,
      );

      expect(await outbox.getNextSyncableItem(), isNull);

      final recovered = await outbox.resetStuckSyncingItems();
      expect(recovered, 1);

      final next = await outbox.getNextSyncableItem();
      expect(next?.id, id);
      expect(next?.status, OutboxStatusEnum.pending);
    });
  });

  group('Reference mapping', () {
    test('save and resolve client → server id', () async {
      await references.saveMapping(clientId: 'profile_1', serverId: 'srv_99');
      expect(await references.getServerId('profile_1'), 'srv_99');
      expect(await references.getServerId('missing'), isNull);

      await references.clearAllMappings();
      expect(await references.getServerId('profile_1'), isNull);
    });
  });

  group('OfflineSyncEngine', () {
    test('FIFO sync deletes items and saves ID mapping', () async {
      final engine = OfflineSyncEngine(
        outboxRepository: outbox,
        referenceRepository: references,
        connectivity: connectivity,
      );

      final processor = ControllableProcessor(
        actionType: 'create_profile',
        successResponse: (item) => {'id': 'server_${item.clientReferenceId}'},
      );
      engine.registerProcessor(processor);

      await outbox.enqueue(
        const OutboxEnqueueParams(
          url: '/a',
          method: 'POST',
          actionType: 'create_profile',
          payload: {'name': 'A'},
          clientReferenceId: 'profile_1',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await outbox.enqueue(
        const OutboxEnqueueParams(
          url: '/b',
          method: 'POST',
          actionType: 'create_profile',
          payload: {'name': 'B'},
          clientReferenceId: 'profile_2',
        ),
      );

      await engine.triggerSync();

      expect(processor.callCount, 2);
      expect(await outbox.getNextSyncableItem(), isNull);
      expect(await references.getServerId('profile_1'), 'server_profile_1');
      expect(await references.getServerId('profile_2'), 'server_profile_2');
      expect(await engine.resolveServerId('profile_1'), 'server_profile_1');

      engine.dispose();
    });

    test('network failure sets nextRetryAt and does not loop forever', () async {
      final engine = OfflineSyncEngine(
        outboxRepository: outbox,
        referenceRepository: references,
        connectivity: connectivity,
      );

      final processor = ControllableProcessor(
        actionType: 'create_profile',
        behavior: (_) => SyncNetworkException('offline blip'),
      );
      engine.registerProcessor(processor);

      final id = await outbox.enqueue(
        const OutboxEnqueueParams(
          url: '/a',
          method: 'POST',
          actionType: 'create_profile',
          payload: {'name': 'A'},
          maxRetries: 3,
        ),
      );

      await engine.triggerSync();

      expect(processor.callCount, 1);

      final items = await outbox.watchOutbox().first;
      final item = items.singleWhere((e) => e.id == id);
      expect(item.status, OutboxStatusEnum.failed);
      expect(item.retryCount, 1);
      expect(item.nextRetryAt, isNotNull);
      expect(item.nextRetryAt!.isAfter(DateTime.now()), isTrue);

      // Still inside backoff window → not syncable yet
      expect(await outbox.getNextSyncableItem(), isNull);

      engine.dispose();
    });

    test('conflict marks item and unblocks queue', () async {
      final engine = OfflineSyncEngine(
        outboxRepository: outbox,
        referenceRepository: references,
        connectivity: connectivity,
      );

      engine.registerProcessor(
        ControllableProcessor(
          actionType: 'create_profile',
          behavior: (item) {
            if (item.payloadAsMap['name'] == 'bad') {
              return SyncConflictException('dup');
            }
            return null;
          },
          successResponse: (item) => {'id': 'ok_${item.id}'},
        ),
      );

      await outbox.enqueue(
        const OutboxEnqueueParams(
          url: '/a',
          method: 'POST',
          actionType: 'create_profile',
          payload: {'name': 'bad'},
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await outbox.enqueue(
        const OutboxEnqueueParams(
          url: '/b',
          method: 'POST',
          actionType: 'create_profile',
          payload: {'name': 'good'},
          clientReferenceId: 'profile_good',
        ),
      );

      await engine.triggerSync();

      final items = await outbox.watchOutbox().first;
      expect(items.length, 1);
      expect(items.first.status, OutboxStatusEnum.conflict);
      expect(await references.getServerId('profile_good'), isNotNull);

      engine.dispose();
    });

    test('initialize recovers stuck syncing items then syncs', () async {
      final id = await outbox.enqueue(
        const OutboxEnqueueParams(
          url: '/a',
          method: 'POST',
          actionType: 'create_profile',
          payload: {'name': 'A'},
          clientReferenceId: 'profile_crash',
        ),
      );
      await outbox.updateOutboxItem(
        id: id,
        status: OutboxStatusEnum.syncing,
        retryCount: 0,
      );

      final engine = OfflineSyncEngine(
        outboxRepository: outbox,
        referenceRepository: references,
        connectivity: connectivity,
      );
      engine.registerProcessor(
        ControllableProcessor(
          actionType: 'create_profile',
          successResponse: (_) => {'id': 'recovered_server'},
        ),
      );

      await engine.initialize();

      expect(await outbox.getNextSyncableItem(), isNull);
      expect(await references.getServerId('profile_crash'), 'recovered_server');

      engine.dispose();
    });

    test('skips sync when offline', () async {
      connectivity.online = false;
      final engine = OfflineSyncEngine(
        outboxRepository: outbox,
        referenceRepository: references,
        connectivity: connectivity,
      );
      final processor = ControllableProcessor(actionType: 'create_profile');
      engine.registerProcessor(processor);

      await outbox.enqueue(
        const OutboxEnqueueParams(
          url: '/a',
          method: 'POST',
          actionType: 'create_profile',
          payload: {'name': 'A'},
        ),
      );

      await engine.triggerSync();
      expect(processor.callCount, 0);
      expect(await outbox.getNextSyncableItem(), isNotNull);

      engine.dispose();
    });
  });

  group('End-to-end OfflineProfileRepository sample', () {
    test('createOffline writes local row + outbox atomically', () async {
      final repo = OfflineProfileRepository(
        profileDao: db.profileDao,
        outboxRepository: outbox,
      );

      final result = await repo.createOffline(
        name: 'Aye',
        email: 'aye@example.com',
      );

      expect(result.localId, greaterThan(0));
      expect(result.clientReferenceId, 'profile_${result.localId}');

      final profile = await db.profileDao.getProfileById(result.localId);
      expect(profile?.name, 'Aye');
      expect(profile?.email, 'aye@example.com');

      final outboxItem = await outbox.getNextSyncableItem();
      expect(outboxItem?.actionType, 'create_profile');
      expect(outboxItem?.clientReferenceId, result.clientReferenceId);
      expect(outboxItem?.payloadAsMap['email'], 'aye@example.com');

      final engine = OfflineSyncEngine(
        outboxRepository: outbox,
        referenceRepository: references,
        connectivity: connectivity,
      );
      engine.registerProcessor(CreateProfileProcessor());

      await engine.triggerSync();

      expect(await outbox.getNextSyncableItem(), isNull);
      expect(
        await references.getServerId(result.clientReferenceId),
        'server_${result.clientReferenceId}',
      );

      engine.dispose();
    });
  });
}
