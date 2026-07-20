import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:clean_archi_frame/core/offline/offline_outbox_item.dart';
import 'package:clean_archi_frame/core/offline/offline_sync_engine.dart';
import 'package:clean_archi_frame/core/offline/outbox_action_processor.dart';
import 'package:clean_archi_frame/core/offline/repositories/offline_outbox_repository.dart';
import 'package:clean_archi_frame/core/services/connectivity_service.dart';
import 'package:clean_archi_frame/core/utils/enums/outbox_status_enum.dart';
import 'package:clean_archi_frame/core/utils/enums/sync_engine_enums.dart';
import 'package:clean_archi_frame/core/utils/exceptions/sync_exceptions.dart';

class FakeOutboxRepository implements OfflineOutboxRepository {
  final List<OfflineOutboxItem> items = [];
  late final StreamController<List<OfflineOutboxItem>> _controller;

  FakeOutboxRepository() {
    _controller = StreamController<List<OfflineOutboxItem>>.broadcast(
      onListen: () => _controller.add(List.from(items)),
    );
  }

  void _notify() {
    if (!_controller.isClosed) {
      _controller.add(List.from(items));
    }
  }

  @override
  Stream<List<OfflineOutboxItem>> watchOutbox() => _controller.stream;

  @override
  Future<int> enqueue(OutboxEnqueueParams params) async {
    final newItem = OfflineOutboxItem(
      id: items.length + 1,
      url: params.url,
      method: params.method,
      actionType: params.actionType,
      payload: params.payload.toString(),
      retryCount: 0,
      clientReferenceId: params.clientReferenceId,
      maxRetries: params.maxRetries,
      status: OutboxStatusEnum.pending,
      createdAt: DateTime.now(),
    );
    items.add(newItem);
    _notify();
    return newItem.id;
  }

  @override
  Future<int> resetStuckSyncingItems() async {
    int count = 0;
    for (var i = 0; i < items.length; i++) {
      if (items[i].status == OutboxStatusEnum.syncing) {
        items[i] = _copyWithStatus(items[i], OutboxStatusEnum.pending);
        count++;
      }
    }
    if (count > 0) _notify();
    return count;
  }

  @override
  Future<OfflineOutboxItem?> getNextSyncableItem() async {
    final now = DateTime.now();
    for (final item in items) {
      if ((item.status == OutboxStatusEnum.pending || item.status == OutboxStatusEnum.failed) &&
          (item.nextRetryAt == null || item.nextRetryAt!.isBefore(now) || item.nextRetryAt!.isAtSameMomentAs(now))) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<DateTime?> getEarliestNextRetryAt() async {
    final now = DateTime.now();
    DateTime? earliest;
    for (final item in items) {
      if (item.nextRetryAt != null && item.nextRetryAt!.isAfter(now)) {
        if (earliest == null || item.nextRetryAt!.isBefore(earliest)) {
          earliest = item.nextRetryAt;
        }
      }
    }
    return earliest;
  }

  @override
  Future<void> updateOutboxItem({
    required int id,
    required OutboxStatusEnum status,
    required int retryCount,
    DateTime? nextRetryAt,
    String? lastError,
    bool clearNextRetryAt = false,
  }) async {
    final index = items.indexWhere((i) => i.id == id);
    if (index != -1) {
      items[index] = OfflineOutboxItem(
        id: items[index].id,
        url: items[index].url,
        method: items[index].method,
        actionType: items[index].actionType,
        payload: items[index].payload,
        retryCount: retryCount,
        clientReferenceId: items[index].clientReferenceId,
        maxRetries: items[index].maxRetries,
        status: status,
        nextRetryAt: clearNextRetryAt ? null : nextRetryAt,
        lastError: lastError,
        createdAt: items[index].createdAt,
        updatedAt: DateTime.now(),
      );
      _notify();
    }
  }

  @override
  Future<void> retryOutboxItem(int id) async {
    await updateOutboxItem(
      id: id,
      status: OutboxStatusEnum.pending,
      retryCount: 0,
      nextRetryAt: null,
      lastError: null,
      clearNextRetryAt: true,
    );
  }

  @override
  Future<void> deleteOutboxItem(int id) async {
    items.removeWhere((i) => i.id == id);
    _notify();
  }

  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) => action();

  OfflineOutboxItem _copyWithStatus(OfflineOutboxItem item, OutboxStatusEnum newStatus) {
    return OfflineOutboxItem(
      id: item.id,
      url: item.url,
      method: item.method,
      actionType: item.actionType,
      payload: item.payload,
      retryCount: item.retryCount,
      clientReferenceId: item.clientReferenceId,
      maxRetries: item.maxRetries,
      status: newStatus,
      nextRetryAt: item.nextRetryAt,
      lastError: item.lastError,
      createdAt: item.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class FakeConnectivity implements ConnectivityChecker {
  bool hasInternetAccess = true;
  final _controller = StreamController<bool>.broadcast();

  @override
  Future<bool> hasInternet() async => hasInternetAccess;

  @override
  Stream<bool> get onStatusChanged => _controller.stream;

  @override
  void dispose() {
    _controller.close();
  }
}

class TestProcessor extends OutboxActionProcessor {
  @override
  final String actionType;
  bool shouldThrowNetworkError = false;
  int processCount = 0;

  TestProcessor(this.actionType);

  @override
  Future<Map<String, dynamic>?> process(OfflineOutboxItem item) async {
    processCount++;
    if (shouldThrowNetworkError) {
      throw SyncNetworkException('Network unavailable');
    }
    return {'status': 'ok'};
  }

  @override
  Future<void> onConflict(Object error, OfflineOutboxItem item) async {}

  @override
  Future<void> onFailure(Object error, OfflineOutboxItem item, int totalRetries) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeOutboxRepository fakeRepo;
  late FakeConnectivity fakeConnectivity;
  late OfflineSyncEngine engine;
  late TestProcessor testProcessor;

  setUp(() {
    fakeRepo = FakeOutboxRepository();
    fakeConnectivity = FakeConnectivity();
    engine = OfflineSyncEngine(
      outboxRepository: fakeRepo,
      connectivity: fakeConnectivity,
    );
    testProcessor = TestProcessor('CREATE_ITEM');
    engine.registerProcessor(testProcessor);
  });

  tearDown(() {
    engine.dispose();
    fakeConnectivity.dispose();
  });

  test('should process item successfully and remove from outbox', () async {
    await fakeRepo.enqueue(
      const OutboxEnqueueParams(
        url: '/api/items',
        method: 'POST',
        actionType: 'CREATE_ITEM',
        payload: {'name': 'Test'},
      ),
    );
    await engine.triggerSync();

    expect(fakeRepo.items, isEmpty);
    expect(testProcessor.processCount, equals(1));
    expect(engine.status, equals(SyncEngineEnums.idle));
  });

  test('should apply exponential backoff nextRetryAt on network error', () async {
    testProcessor.shouldThrowNetworkError = true;
    await fakeRepo.enqueue(
      const OutboxEnqueueParams(
        url: '/api/items',
        method: 'POST',
        actionType: 'CREATE_ITEM',
        payload: {'name': 'Test'},
      ),
    );
    await engine.triggerSync();

    expect(fakeRepo.items.length, equals(1));
    final item = fakeRepo.items.first;
    expect(item.status, equals(OutboxStatusEnum.failed));
    expect(item.retryCount, equals(1));
    expect(item.nextRetryAt, isNotNull);
    expect(item.nextRetryAt!.isAfter(DateTime.now()), isTrue);
  });

  test('should skip syncing when offline', () async {
    fakeConnectivity.hasInternetAccess = false;
    await fakeRepo.enqueue(
      const OutboxEnqueueParams(
        url: '/api/items',
        method: 'POST',
        actionType: 'CREATE_ITEM',
        payload: {'name': 'Test'},
      ),
    );
    await engine.triggerSync();

    expect(fakeRepo.items.length, equals(1));
    expect(fakeRepo.items.first.status, equals(OutboxStatusEnum.pending));
    expect(engine.status, equals(SyncEngineEnums.offline));
  });
}
