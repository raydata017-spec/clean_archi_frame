import 'dart:async';
import 'dart:developer' as dev;

import '../services/connectivity_service.dart';
import '../utils/enums/outbox_status_enum.dart';
import '../utils/enums/sync_engine_enums.dart';
import '../utils/exceptions/sync_exceptions.dart';
import '../utils/extensions/duration_extension.dart';
import 'repositories/local_reference_repository.dart';
import 'sync_config.dart';
import 'outbox_action_processor.dart';
import 'offline_cleanup_handler.dart';
import 'repositories/offline_outbox_repository.dart';
import 'offline_outbox_item.dart';

class OfflineSyncEngine {
  final OfflineOutboxRepository _outboxRepository;
  final LocalReferenceRepository _referenceRepository;
  final SyncConfig _config;
  final ConnectivityChecker _connectivity;

  final Map<String, OutboxActionProcessor> _processors = {};
  final List<OfflineCleanupHandler> _cleanupHandlers = [];

  SyncEngineEnums _status = SyncEngineEnums.idle;
  bool _isProcessing = false;
  bool _initialized = false;
  StreamSubscription<bool>? _connectivitySub;
  StreamSubscription<List<OfflineOutboxItem>>? _outboxSub;
  Timer? _retryTimer;

  SyncEngineEnums get status => _status;
  bool get isProcessing => _isProcessing;

  final _statusController = StreamController<SyncEngineEnums>.broadcast();
  Stream<SyncEngineEnums> get statusStream => _statusController.stream;

  OfflineSyncEngine({
    required LocalReferenceRepository referenceRepository,
    required OfflineOutboxRepository outboxRepository,
    SyncConfig config = const SyncConfig(),
    ConnectivityChecker? connectivity,
  })  : _outboxRepository = outboxRepository,
        _referenceRepository = referenceRepository,
        _config = config,
        _connectivity = connectivity ?? ConnectivityService();

  /// Must be called once after construction (e.g. from the Riverpod provider).
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final recovered = await _outboxRepository.resetStuckSyncingItems();
    if (recovered > 0) {
      dev.log(
        '♻️ Recovered $recovered stuck syncing item(s) → pending',
        name: 'OfflineSyncEngine',
      );
    }

    _initListeners();
    await triggerSync();
  }

  void registerProcessor(OutboxActionProcessor processor) {
    _processors[processor.actionType] = processor;
    dev.log(
      '🔌 Registered outbox processor for action: ${processor.actionType}',
      name: 'OfflineSyncEngine',
    );
  }

  void registerCleanupHandler(OfflineCleanupHandler handler) {
    _cleanupHandlers.add(handler);
    dev.log('🧹 Registered database cleanup handler', name: 'OfflineSyncEngine');
  }

  void _initListeners() {
    _connectivitySub = _connectivity.onStatusChanged.listen((hasInternet) {
      dev.log(
        '🌐 Connectivity changed: hasInternet=$hasInternet',
        name: 'OfflineSyncEngine',
      );
      if (hasInternet) {
        triggerSync();
      } else {
        _updateStatus(SyncEngineEnums.offline);
      }
    });

    _outboxSub = _outboxRepository.watchOutbox().listen((items) {
      final hasReadyItems = items.any(
        (item) =>
            (item.status == OutboxStatusEnum.pending ||
                item.status == OutboxStatusEnum.failed) &&
            item.isReadyToSync,
      );
      if (hasReadyItems && _status != SyncEngineEnums.offline) {
        dev.log(
          '📥 Ready pending items detected. Triggering sync...',
          name: 'OfflineSyncEngine',
        );
        triggerSync();
      } else {
        _scheduleNextRetry();
      }
    });
  }

  void _updateStatus(SyncEngineEnums newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(newStatus);
      dev.log(
        '🔄 Sync engine status changed to: $newStatus',
        name: 'OfflineSyncEngine',
      );
    }
  }

  /// Schedules a one-shot timer for the earliest future retry.
  Future<void> _scheduleNextRetry() async {
    _retryTimer?.cancel();
    final nextAt = await _outboxRepository.getEarliestNextRetryAt();
    if (nextAt == null) return;

    final delay = nextAt.difference(DateTime.now());
    if (delay.isNegative) {
      triggerSync();
      return;
    }

    dev.log(
      '⏰ Next retry scheduled in ${delay.inSeconds}s',
      name: 'OfflineSyncEngine',
    );
    _retryTimer = Timer(delay, () {
      triggerSync();
    });
  }

  /// Triggers the FIFO syncing loop.
  Future<void> triggerSync() async {
    if (_isProcessing) {
      dev.log(
        '⚠️ Sync already in progress. Skipping trigger.',
        name: 'OfflineSyncEngine',
      );
      return;
    }

    final hasInternet = await _connectivity.hasInternet();
    if (!hasInternet) {
      dev.log('🚫 Cannot sync: Offline', name: 'OfflineSyncEngine');
      _updateStatus(SyncEngineEnums.offline);
      await _scheduleNextRetry();
      return;
    }

    _isProcessing = true;
    _updateStatus(SyncEngineEnums.syncing);
    dev.log('🚀 Starting FIFO outbox sync loop...', name: 'OfflineSyncEngine');

    try {
      while (true) {
        final item = await _outboxRepository.getNextSyncableItem();
        if (item == null) {
          dev.log(
            '🏁 No more syncable items in the outbox.',
            name: 'OfflineSyncEngine',
          );
          break;
        }

        final processor = _processors[item.actionType];
        if (processor == null) {
          dev.log(
            '❌ No processor registered for action type: ${item.actionType}',
            name: 'OfflineSyncEngine',
          );
          await _outboxRepository.updateOutboxItem(
            id: item.id,
            status: OutboxStatusEnum.failed,
            retryCount: item.maxRetries,
            lastError: 'No processor registered for ${item.actionType}',
            clearNextRetryAt: true,
          );
          continue;
        }

        await _processOutboxItem(item, processor);
      }

      final nextItem = await _outboxRepository.getNextSyncableItem();
      if (nextItem == null) {
        await runDatabaseCleanup();
        _updateStatus(
          _status == SyncEngineEnums.offline
              ? SyncEngineEnums.offline
              : SyncEngineEnums.idle,
        );
        await _scheduleNextRetry();
      }
    } catch (e) {
      dev.log('🚨 Critical error in sync loop: $e', name: 'OfflineSyncEngine');
      _updateStatus(SyncEngineEnums.error);
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _processOutboxItem(
    OfflineOutboxItem item,
    OutboxActionProcessor processor,
  ) async {
    await _outboxRepository.updateOutboxItem(
      id: item.id,
      status: OutboxStatusEnum.syncing,
      retryCount: item.retryCount,
      clearNextRetryAt: true,
    );

    try {
      dev.log(
        '📤 Processing outbox item #${item.id} (Action: ${item.actionType})',
        name: 'OfflineSyncEngine',
      );

      final response = await processor.process(item);

      if (response != null && item.clientReferenceId != null) {
        final serverId = response['id']?.toString();
        if (serverId != null) {
          await _referenceRepository.saveMapping(
            clientId: item.clientReferenceId!,
            serverId: serverId,
          );
          dev.log(
            '🔗 Saved Mapping: ${item.clientReferenceId} -> $serverId',
            name: 'OfflineSyncEngine',
          );
        }
      }

      await _outboxRepository.deleteOutboxItem(item.id);
      dev.log(
        '✅ Successfully processed item #${item.id}',
        name: 'OfflineSyncEngine',
      );
    } on SyncConflictException catch (error) {
      await _outboxRepository.updateOutboxItem(
        id: item.id,
        status: OutboxStatusEnum.conflict,
        retryCount: item.retryCount,
        lastError: error.toString(),
        clearNextRetryAt: true,
      );
      await processor.onConflict(error, item);
    } on SyncNetworkException catch (error) {
      await _handleRetryableError(item, processor, error);
    } on SyncServerException catch (error) {
      await _handleRetryableError(item, processor, error);
    } catch (error) {
      await _handleFatalError(item, processor, error);
    }
  }

  /// One-shot sync for background tasks.
  Future<void> syncOnce() async {
    if (_isProcessing) return;
    _isProcessing = true;
    _updateStatus(SyncEngineEnums.syncing);

    try {
      final hasInternet = await _connectivity.hasInternet();
      if (!hasInternet) {
        _updateStatus(SyncEngineEnums.offline);
        return;
      }

      dev.log('🚀 Background Sync Started...', name: 'OfflineSyncEngine');

      while (true) {
        final item = await _outboxRepository.getNextSyncableItem();
        if (item == null) {
          dev.log(
            '🏁 No more items to sync. Background Sync Finished.',
            name: 'OfflineSyncEngine',
          );
          break;
        }

        final processor = _processors[item.actionType];
        if (processor == null) {
          await _outboxRepository.updateOutboxItem(
            id: item.id,
            status: OutboxStatusEnum.failed,
            retryCount: item.maxRetries,
            lastError: 'Processor missing',
            clearNextRetryAt: true,
          );
          continue;
        }

        await _processOutboxItem(item, processor);
      }

      _updateStatus(SyncEngineEnums.idle);
    } catch (e) {
      dev.log('❌ Background Sync Error: $e', name: 'OfflineSyncEngine');
      _updateStatus(SyncEngineEnums.error);
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> runDatabaseCleanup() async {
    dev.log(
      '🧹 Running database cleanup with retention: ${_config.cleanupDuration}',
      name: 'OfflineSyncEngine',
    );
    for (final handler in _cleanupHandlers) {
      try {
        await handler.cleanup(_config.cleanupDuration);
      } catch (e) {
        dev.log('❌ Error running cleanup handler: $e', name: 'OfflineSyncEngine');
      }
    }
  }

  Future<void> _handleRetryableError(
    OfflineOutboxItem item,
    OutboxActionProcessor processor,
    Object error,
  ) async {
    final newRetryCount = item.retryCount + 1;
    final maxRetries = item.maxRetries;

    if (newRetryCount >= maxRetries) {
      dev.log(
        '🚨 Item #${item.id} exceeded max retries. Marking as failed.',
        name: 'OfflineSyncEngine',
      );
      await _outboxRepository.updateOutboxItem(
        id: item.id,
        status: OutboxStatusEnum.failed,
        retryCount: newRetryCount,
        lastError: error.toString(),
        clearNextRetryAt: true,
      );
      await processor.onFailure(error, item, newRetryCount);
      _updateStatus(SyncEngineEnums.error);
      return;
    }

    final delay = newRetryCount.getExponentialDelay();
    final nextRetryAt = DateTime.now().add(delay);
    dev.log(
      '⏳ Item #${item.id} will retry after $delay (at $nextRetryAt).',
      name: 'OfflineSyncEngine',
    );

    await _outboxRepository.updateOutboxItem(
      id: item.id,
      status: OutboxStatusEnum.failed,
      retryCount: newRetryCount,
      lastError: error.toString(),
      nextRetryAt: nextRetryAt,
    );
    await _scheduleNextRetry();
  }

  Future<void> _handleFatalError(
    OfflineOutboxItem item,
    OutboxActionProcessor processor,
    Object error,
  ) async {
    final newRetryCount = item.retryCount + 1;
    await _outboxRepository.updateOutboxItem(
      id: item.id,
      status: OutboxStatusEnum.failed,
      retryCount: item.maxRetries,
      lastError: error.toString(),
      clearNextRetryAt: true,
    );
    await processor.onFailure(error, item, newRetryCount);
    _updateStatus(SyncEngineEnums.error);
  }

  /// Resolves a client reference to its server ID (if mapped).
  Future<String?> resolveServerId(String clientId) {
    return _referenceRepository.getServerId(clientId);
  }

  void dispose() {
    _retryTimer?.cancel();
    _connectivitySub?.cancel();
    _outboxSub?.cancel();
    _statusController.close();
  }
}
