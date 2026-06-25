import 'dart:async';
import 'dart:developer' as dev;

import 'package:connectivity_plus/connectivity_plus.dart';

import '../utils/enums/outbox_status_enum.dart';
import '../utils/enums/sync_engine_enums.dart';
import '../utils/exceptions/sync_exceptions.dart';
import '../utils/extensions/duration_extension.dart';
import 'local_reference_repository.dart';
import 'sync_config.dart';
import 'outbox_action_processor.dart';
import 'offline_cleanup_handler.dart';
import 'offline_outbox_repository.dart';
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

  // UI ဘက်သို့ Engine ၏ အခြေအနေပြောင်းလဲမှုများ လှမ်းအကြောင်းကြားရန် Broadcast Stream Controller
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
    // 1. အင်တာနက်လိုင်း အပြောင်းအလဲကို စဉ်ဆက်မပြတ် Listen လုပ်
    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
      final hasConnection = !results.contains(ConnectivityResult.none);
      dev.log('🌐 Connectivity changed: hasConnection=$hasConnection (results=$results)', name: 'OfflineSyncEngine');
      if (hasConnection) {
        triggerSync();
      } else {
        _updateStatus(SyncEngineEnums.offline);
      }
    });

    // 2. Local Database (Outbox) ထဲသို့ ဒေတာအသစ်ရောက်လာခြင်း သို့မဟုတ် Update ဖြစ်ခြင်းကို စောင့်ကြည့်သည်
    _outboxSub = _outboxRepository.watchOutbox().listen((items) {
      final hasPendingItems = items.any((item) => item.status == OutboxStatusEnum.pending); // ပို့ရန်ကျန်သေးသော 'pending' ဒေတာ ပါ၊ မပါ စစ်ဆေးသည်
      if (hasPendingItems && _status != SyncEngineEnums.offline) {
        // ပို့ရန်ရှိပြီး အော့ဖ်လိုင်းမဟုတ်ပါက
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
          // ကျန်ရှိနေသော တန်းစီဇယား Block ဖြစ်မသွားစေရန် 'failed' သတ်မှတ်ပြီး ကျော်သည်
          await _outboxRepository.updateOutboxItem(id: item.id, status: OutboxStatusEnum.failed, retryCount: item.retryCount, lastError: 'No processor registered for ${item.actionType}');
          continue;
        }

        // ပို့တော့မည့် Item ကို Local Database တွင် 'syncing' အခြေအနေသို့ ပြောင်းလဲသည်
        await _outboxRepository.updateOutboxItem(id: item.id, status: OutboxStatusEnum.syncing, retryCount: item.retryCount);

        try {
          dev.log('📤 Processing outbox item #${item.id} (Action: ${item.actionType})', name: 'OfflineSyncEngine');

          // 🛑 ဤနေရာသည် သက်ဆိုင်ရာ Processor ကိုသုံး၍ ဆာဗာသို့ အင်တာနက်မှတစ်ဆင့် အချက်အလက် အမှန်တကယ် ပို့ဆောင်သည့်နေရာဖြစ်သည်
          final response = await processor.process(item);

          // Relationship Handling:
          // Server ဆီက response ရလာပြီး item မှာ clientReferenceId ရှိနေရင်
          // တခြား pending ဖြစ်နေတဲ့ items တွေထဲမှာ ဒီ reference ကို သုံးထားတာရှိမရှိ စစ်ပြီး Update လုပ်ပေးမယ်
          if (response != null && item.clientReferenceId != null) {
            final serverId = response['id']?.toString();
            if (serverId != null) {
              // Mapping Table ထဲတွင် client_id = server_id ဆိုပြီး သိမ်းလိုက်ပါပြီ
              await _referenceRepository.saveMapping(clientId: item.clientReferenceId!, serverId: serverId);
              dev.log('🔗 Saved Reference Mapping: ${item.clientReferenceId} -> $serverId', name: 'OfflineSyncEngine');
            }
          }

          // အောင်မြင်လျှင် Outbox မှ ဖျက်
          await _outboxRepository.deleteOutboxItem(item.id);
          dev.log('✅ Successfully processed and deleted outbox item #${item.id}', name: 'OfflineSyncEngine');
        } on SyncConflictException catch (error) {
          dev.log('❌ Failed to process outbox item #${item.id}: $error', name: 'OfflineSyncEngine');

          // 🛑 ဒေတာထပ်နေသည့် Conflict Error ကို ဖမ်းမိသည့်အခါ
          dev.log('⚠️ Conflict detected for item #${item.id}. Invoking conflict handler...', name: 'OfflineSyncEngine');
          await _outboxRepository.updateOutboxItem(id: item.id, status: OutboxStatusEnum.conflict, retryCount: item.retryCount, lastError: error.toString());
          await processor.onConflict(error, item);
          dev.log('⚠️ Conflict handled. Queue unblocked.', name: 'OfflineSyncEngine');
        } on SyncNetworkException catch (error) {
          // 🌐 Network ပိုင်းဆိုင်ရာ Error တက်သည့်အခါ (Retry ပြန်လုပ်မည်)
          await _handleRetryableError(item, processor, error);
        } on SyncServerException catch (error) {
          // 🖥️ Server ပိုင်းဆိုင်ရာ Error (5xx) တက်သည့်အခါ (Retry ပြန်လုပ်မည်)
          await _handleRetryableError(item, processor, error);
        } catch (error) {
          // ❌ အခြား မမျှော်လင့်ထားသော Error များ
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

  /// တစ်ခုချင်းစီသော Outbox Item ကို logic အပြည့်အစုံဖြင့် ပို့ဆောင်ပေးသည့် method
  Future<void> _processOutboxItem(OfflineOutboxItem item, OutboxActionProcessor processor) async {
    // 1. အခြေအနေအား 'syncing' သို့ ပြောင်းလဲပါ
    await _outboxRepository.updateOutboxItem(id: item.id, status: OutboxStatusEnum.syncing, retryCount: item.retryCount);

    try {

      dev.log('📤 Processing outbox item #${item.id} (Action: ${item.actionType})', name: 'OfflineSyncEngine');

      // 3. ဆာဗာသို့ ပို့ဆောင်ခြင်း
      final response = await processor.process(item);

      // 4. အောင်မြင်လျှင် Mapping သိမ်းဆည်းခြင်း
      if (response != null && item.clientReferenceId != null) {
        final serverId = response['id']?.toString();
        if (serverId != null) {
          await _referenceRepository.saveMapping(clientId: item.clientReferenceId!, serverId: serverId);
          dev.log('🔗 Saved Mapping: ${item.clientReferenceId} -> $serverId', name: 'OfflineSyncEngine');
        }
      }

      // 5. အောင်မြင်လျှင် Outbox မှ ဖျက်ပါ
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

  /// Background Task များမှ လှမ်းခေါ်ရန်အတွက် One-shot Sync Method
  Future<void> syncOnce() async {
    if (_isProcessing) return;
    _isProcessing = true;
    _updateStatus(SyncEngineEnums.syncing);

    try {
      dev.log('🚀 Background Sync Started...', name: 'OfflineSyncEngine');

      // Outbox ထဲမှာ ပို့ဖို့ကျန်တာ ရှိနေသရွေ့ Loop ပတ်ပြီး ပို့နေမည်
      while (true) {
        final item = await _outboxRepository.getNextSyncableItem();
        if (item == null) {
          dev.log('🏁 No more items to sync. Background Sync Finished.', name: 'OfflineSyncEngine');
          break;
        }

        final processor = _processors[item.actionType];
        if (processor == null) {
          dev.log('❌ Processor not found for action: ${item.actionType}', name: 'OfflineSyncEngine');
          // Processor မရှိလျှင် Queue ပိတ်မနေစေရန် ကူးကျော်သည် သို့မဟုတ် Failed ပေးသည်
          await _outboxRepository.updateOutboxItem(id: item.id, status: OutboxStatusEnum.failed, retryCount: item.retryCount, lastError: 'Processor missing');
          continue;
        }

        // လက်ရှိ item အား ပို့ဆောင်ခြင်း (ယခင်ရေးထားသည့် try-catch logic အတိုင်း ပို့ပါမည်)
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
      dev.log('⏳ Error တက်သဖြင့် Item #${item.id} ကို $delay အကြာမှ ပြန်လည်စမ်းသပ်ပါမည်။', name: 'OfflineSyncEngine');

      await _outboxRepository.updateOutboxItem(id: item.id, status: OutboxStatusEnum.failed, retryCount: newRetryCount, lastError: error.toString());
    }
    _updateStatus(SyncEngineEnums.error);
  }

  Future<void> _handleFatalError(OfflineOutboxItem item, OutboxActionProcessor processor, Object error) async {
    // ချက်ချင်း Failed သတ်မှတ်မည့် အပိုင်း
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
