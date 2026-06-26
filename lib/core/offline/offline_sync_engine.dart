import 'dart:async';
import 'dart:developer' as dev;

import 'package:connectivity_plus/connectivity_plus.dart';

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
  final Connectivity _connectivity;

  final Map<String, OutboxActionProcessor> _processors = {};
  final List<OfflineCleanupHandler> _cleanupHandlers = [];

  SyncEngineEnums _status = SyncEngineEnums.idle;
  bool _isProcessing = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  StreamSubscription<List<OfflineOutboxItem>>? _outboxSub;

  SyncEngineEnums get status => _status;
  bool get isProcessing => _isProcessing;

  // Broadcast stream controller to notify the UI about engine status changes
  final _statusController = StreamController<SyncEngineEnums>.broadcast();
  Stream<SyncEngineEnums> get statusStream => _statusController.stream;

  OfflineSyncEngine({required LocalReferenceRepository referenceRepository, required OfflineOutboxRepository outboxRepository, SyncConfig config = const SyncConfig(), Connectivity? connectivity})
      : _outboxRepository = outboxRepository,
        _referenceRepository = referenceRepository,
        _config = config,
        _connectivity = connectivity ?? Connectivity() {
    _initListeners();
  }

  //
  void registerProcessor(OutboxActionProcessor processor) {
    _processors[processor.actionType] = processor;
    dev.log('🔌 Registered outbox processor for action: ${processor.actionType}', name: 'OfflineSyncEngine');
  }

  void registerCleanupHandler(OfflineCleanupHandler handler) {
    _cleanupHandlers.add(handler);
    dev.log('🧹 Registered database cleanup handler', name: 'OfflineSyncEngine');
  }

  void _initListeners() {
    // 1. Continuously listen for internet connectivity changes
    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
      final hasConnection = !results.contains(ConnectivityResult.none);
      dev.log('🌐 Connectivity changed: hasConnection=$hasConnection (results=$results)', name: 'OfflineSyncEngine');
      if (hasConnection) {
        triggerSync();
      } else {
        _updateStatus(SyncEngineEnums.offline);
      }
    });

    // 2. Watch for new or updated data arriving in the local outbox database
    _outboxSub = _outboxRepository.watchOutbox().listen((items) {
      final hasPendingItems = items.any((item) => item.status == OutboxStatusEnum.pending); // Check whether there are remaining pending items to send
      if (hasPendingItems && _status != SyncEngineEnums.offline) {
        // If there are pending items and the app is online
        dev.log('📥 Pending items detected in outbox. Triggering sync...', name: 'OfflineSyncEngine');
        triggerSync();
      }
    });
  }

  // Engine ၏ (Status) ပြောင်းလဲမှုကို UI ဘက်သို့ လှမ်းပို့
  void _updateStatus(SyncEngineEnums newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(newStatus);
      dev.log('🔄 Sync engine status changed to: $newStatus', name: 'OfflineSyncEngine');
    }
  }

  /// Triggers the FIFO syncing loop.
  Future<void> triggerSync() async {
    if (_isProcessing) {
      dev.log('⚠️ Sync already in progress. Skipping trigger.', name: 'OfflineSyncEngine');
      return;
    }

    // Check internet connection before starting
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      dev.log('🚫 Cannot sync: Offline', name: 'OfflineSyncEngine');
      _updateStatus(SyncEngineEnums.offline);
      return;
    }

    _isProcessing = true;
    _updateStatus(SyncEngineEnums.syncing);

    dev.log('🚀 Starting FIFO outbox sync loop...', name: 'OfflineSyncEngine');

    try {
      while (true) {
        // Fetch next syncable item in FIFO order
        final item = await _outboxRepository.getNextSyncableItem();
        if (item == null) {
          dev.log('🏁 No more syncable items in the outbox.', name: 'OfflineSyncEngine');
          break;
        }

        final processor = _processors[item.actionType];
        if (processor == null) {
          dev.log('❌ Error: No processor registered for action type: ${item.actionType}', name: 'OfflineSyncEngine');
          // Mark as failed and skip so the remaining queue does not block
          await _outboxRepository.updateOutboxItem(id: item.id, status: OutboxStatusEnum.failed, retryCount: item.retryCount, lastError: 'No processor registered for ${item.actionType}');
          continue;
        }

        // Mark the item in the local database as 'syncing' before sending
        await _outboxRepository.updateOutboxItem(id: item.id, status: OutboxStatusEnum.syncing, retryCount: item.retryCount);

        try {
          dev.log('📤 Processing outbox item #${item.id} (Action: ${item.actionType})', name: 'OfflineSyncEngine');

          // 🛑 This is where the associated processor sends the actual data to the server over the internet
          final response = await processor.process(item);

          // Relationship Handling:
          // If a response returns from the server and the item has a clientReferenceId
          // Check for other pending items using that reference and update them as needed
          if (response != null && item.clientReferenceId != null) {
            final serverId = response['id']?.toString();
            if (serverId != null) {
              // Store the client_id to server_id mapping in the reference table
              await _referenceRepository.saveMapping(clientId: item.clientReferenceId!, serverId: serverId);
              dev.log('🔗 Saved Reference Mapping: ${item.clientReferenceId} -> $serverId', name: 'OfflineSyncEngine');
            }
          }

          // Delete from the outbox when successful
          await _outboxRepository.deleteOutboxItem(item.id);
          dev.log('✅ Successfully processed and deleted outbox item #${item.id}', name: 'OfflineSyncEngine');
        } on SyncConflictException catch (error) {
          dev.log('❌ Failed to process outbox item #${item.id}: $error', name: 'OfflineSyncEngine');

          // 🛑 Conflict error
          dev.log('⚠️ Conflict detected for item #${item.id}. Invoking conflict handler...', name: 'OfflineSyncEngine');
          await _outboxRepository.updateOutboxItem(id: item.id, status: OutboxStatusEnum.conflict, retryCount: item.retryCount, lastError: error.toString());
          await processor.onConflict(error, item);
          dev.log('⚠️ Conflict handled. Queue unblocked.', name: 'OfflineSyncEngine');
        } on SyncNetworkException catch (error) {
          // 🌐 Handle network error
          await _handleRetryableError(item, processor, error);
        } on SyncServerException catch (error) {
          // 🖥️ Handle Server Error (5xx)
          await _handleRetryableError(item, processor, error);
        } catch (error) {
          // ❌ Unexpected error
          await _handleFatalError(item, processor, error);
        }
      }

      // If we cleared the queue, run database cleaning
      final nextItem = await _outboxRepository.getNextSyncableItem();
      if (nextItem == null) {
        await runDatabaseCleanup();
        _updateStatus(SyncEngineEnums.idle);
      }
    } catch (e) {
      dev.log('🚨 Critical error in sync loop: $e', name: 'OfflineSyncEngine');
      _updateStatus(SyncEngineEnums.error);
    } finally {
      _isProcessing = false;
    }
  }

  /// One-shot method to fully process each outbox item
  Future<void> _processOutboxItem(OfflineOutboxItem item, OutboxActionProcessor processor) async {
    // 1. Change the status to 'syncing'
    await _outboxRepository.updateOutboxItem(id: item.id, status: OutboxStatusEnum.syncing, retryCount: item.retryCount);

    try {
      dev.log('📤 Processing outbox item #${item.id} (Action: ${item.actionType})', name: 'OfflineSyncEngine');

      // 3. Send to the server
      final response = await processor.process(item);

      // 4. Save mapping on success
      if (response != null && item.clientReferenceId != null) {
        final serverId = response['id']?.toString();
        if (serverId != null) {
          await _referenceRepository.saveMapping(clientId: item.clientReferenceId!, serverId: serverId);
          dev.log('🔗 Saved Mapping: ${item.clientReferenceId} -> $serverId', name: 'OfflineSyncEngine');
        }
      }

      // 5. Delete from the outbox on success
      await _outboxRepository.deleteOutboxItem(item.id);
      dev.log('✅ Successfully processed item #${item.id}', name: 'OfflineSyncEngine');
    } on SyncConflictException catch (error) {
      await _outboxRepository.updateOutboxItem(id: item.id, status: OutboxStatusEnum.conflict, retryCount: item.retryCount, lastError: error.toString());
      await processor.onConflict(error, item);
    } on SyncNetworkException catch (error) {
      await _handleRetryableError(item, processor, error);
    } on SyncServerException catch (error) {
      await _handleRetryableError(item, processor, error);
    } catch (error) {
      await _handleFatalError(item, processor, error);
    }
  }

  /// One-shot sync method for background tasks to invoke
  Future<void> syncOnce() async {
    if (_isProcessing) return;
    _isProcessing = true;
    _updateStatus(SyncEngineEnums.syncing);

    try {
      dev.log('🚀 Background Sync Started...', name: 'OfflineSyncEngine');

      // Loop and send while there are remaining items in the outbox
      while (true) {
        final item = await _outboxRepository.getNextSyncableItem();
        if (item == null) {
          dev.log('🏁 No more items to sync. Background Sync Finished.', name: 'OfflineSyncEngine');
          break;
        }

        final processor = _processors[item.actionType];
        if (processor == null) {
          dev.log('❌ Processor not found for action: ${item.actionType}', name: 'OfflineSyncEngine');
          // Skip or mark failed so the queue does not stall if the processor is missing
          await _outboxRepository.updateOutboxItem(id: item.id, status: OutboxStatusEnum.failed, retryCount: item.retryCount, lastError: 'Processor missing');
          continue;
        }

        // Send the current item using the previously written try-catch logic
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

  /// Runs database cleanup handlers to remove old synced records
  Future<void> runDatabaseCleanup() async {
    dev.log('🧹 Running database cleanup with retention: ${_config.cleanupDuration}', name: 'OfflineSyncEngine');
    for (final handler in _cleanupHandlers) {
      try {
        await handler.cleanup(_config.cleanupDuration);
      } catch (e) {
        dev.log('❌ Error running cleanup handler: $e', name: 'OfflineSyncEngine');
      }
    }
  }

  Future<void> _handleRetryableError(OfflineOutboxItem item, OutboxActionProcessor processor, Object error) async {
    final newRetryCount = item.retryCount + 1;
    final maxRetries = item.maxRetries;

    if (newRetryCount >= maxRetries) {
      dev.log('🚨 Item #${item.id} exceeded max retries. Marking as failed.', name: 'OfflineSyncEngine');
      await _outboxRepository.updateOutboxItem(id: item.id, status: OutboxStatusEnum.failed, retryCount: newRetryCount, lastError: error.toString());
      await processor.onFailure(error, item, newRetryCount);
    } else {
      final Duration delay = newRetryCount.getExponentialDelay(maxRetries);
      dev.log('⏳ Due to the error, item #${item.id} will retry after $delay.', name: 'OfflineSyncEngine');

      await _outboxRepository.updateOutboxItem(id: item.id, status: OutboxStatusEnum.failed, retryCount: newRetryCount, lastError: error.toString());
    }
    _updateStatus(SyncEngineEnums.error);
  }

  Future<void> _handleFatalError(OfflineOutboxItem item, OutboxActionProcessor processor, Object error) async {
    // Section to immediately mark the item as failed
    final newRetryCount = item.retryCount + 1;
    await _outboxRepository.updateOutboxItem(id: item.id, status: OutboxStatusEnum.failed, retryCount: newRetryCount, lastError: error.toString());
    await processor.onFailure(error, item, newRetryCount);
    _updateStatus(SyncEngineEnums.error);
  }

  void dispose() {
    _connectivitySub?.cancel();
    _outboxSub?.cancel();
    _statusController.close();
  }
}
