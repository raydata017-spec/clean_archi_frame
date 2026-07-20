# Offline-First Framework & Outbox Architecture

This module implements the **Offline-First Outbox Pattern** for the `clean_archi_frame` Clean Architecture framework.

---

## 🏛️ Architecture Overview

The offline-first architecture guarantees that user write actions are **saved locally first** and **synchronized asynchronously** to the backend server when internet connectivity is available.

```
┌────────────────────────────────────────────────────────┐
│                   UI Layer (Screen / Riverpod)         │
└───────────────────────────┬────────────────────────────┘
                            │ (1) Call Repository Method
┌───────────────────────────▼────────────────────────────┐
│              OfflineWriteCoordinator                   │
│         (Atomic Local Write + Enqueue Action)          │
└──────────────┬──────────────────────────┬──────────────┘
               │ (2a) Local Mutation      │ (2b) Enqueue Outbox Item
┌──────────────▼──────────┐    ┌──────────▼──────────────┐
│  Drift Local SQLite DB  │    │  Outbox Table (Pending) │
└─────────────────────────┘    └──────────┬──────────────┘
                                          │ (3) Watch / Trigger Sync
                               ┌──────────▼──────────────┐
                               │   OfflineSyncEngine     │
                               └──────────┬──────────────┘
                                          │ (4) Dispatch to Processor
                               ┌──────────▼──────────────┐
                               │ OutboxActionProcessor   │
                               └──────────┬──────────────┘
                                          │ (5) Remote HTTP Call (Dio)
                               ┌──────────▼──────────────┐
                               │      Backend API        │
                               └─────────────────────────┘
```

---

## 🆔 Dual-ID Strategy

- **Primary Preference**: Always use **Dual IDs** on local database entities:
  - `id` (Client UUID / Local ID): Generated immediately on the client side before writing.
  - `server_id` (Text / Nullable): Updated when the backend returns the official server identifier.
- **Cross-Action References**:
  - `LocalReferenceRepository` ([local_reference_repository.dart](file:///d:/Projects/clean_archi_frame/lib/core/offline/repositories/local_reference_repository.dart)) is available in `offline_di.dart` for handling cross-action reference rewriting when dependent outbox actions must resolve a client ID to a server ID before sync.

---

## ⚡ Atomic Writes with `OfflineWriteCoordinator`

Local entity mutations and Outbox queue entries **MUST** be performed atomically inside a single database transaction.

```dart
final coordinator = ref.read(offlineWriteCoordinatorProvider);

await coordinator.writeLocalThenEnqueue(
  localWrite: () async {
    // 1) Write to local Drift table
    await profileDao.insertProfile(localEntity);
  },
  params: OutboxEnqueueParams(
    url: '/api/profiles',
    method: 'POST',
    actionType: 'create_profile',
    clientReferenceId: clientUuid,
    payload: {'id': clientUuid, 'name': 'Aye Aye'},
  ),
);
```

---

## 🔌 Creating an Outbox Action Processor

Each feature module defines an `OutboxActionProcessor` to handle remote API execution for specific `actionType`s.

```dart
class UpdateProfileProcessor extends OutboxActionProcessor {
  @override
  String get actionType => 'update_profile';

  @override
  Future<Map<String, dynamic>?> process(OfflineOutboxItem item) async {
    final payload = item.payloadAsMap;
    // Perform remote API call using Dio / HTTP client
    // If conflict occurs: throw SyncConflictException('Conflict message');
    // If network fails: throw SyncNetworkException('Network failure');
    return {'status': 'updated'};
  }

  @override
  Future<void> onConflict(Object error, OfflineOutboxItem item) async {
    // Mark local entity as conflicted or notify UI
  }

  @override
  Future<void> onFailure(Object error, OfflineOutboxItem item, int currentRetries) async {
    // Log or show notification after max retries exhausted
  }
}
```

### Auto-Registration via Dependency Injection

Add your processor provider to `outboxProcessorsProvider` in [lib/core/di/offline_di.dart](file:///d:/Projects/clean_archi_frame/lib/core/di/offline_di.dart):

```dart
final outboxProcessorsProvider = Provider<List<OutboxActionProcessor>>((ref) {
  return [
    ref.watch(createProfileProcessorProvider),
    ref.watch(updateProfileProcessorProvider),
  ];
});
```

`OfflineSyncEngine` automatically registers all processors upon initialization.

---

## 🔁 Exponential Backoff & Crash Recovery

1. **Exponential Backoff**:
   - On retryable network failures (`SyncNetworkException`, `SyncServerException`), `OfflineSyncEngine` calculates exponential delay timers (`2^retryCount * baseDelaySeconds`) and sets `nextRetryAt` in the database.
   - Items are held until their `nextRetryAt` timestamp expires.
2. **Stuck-Sync Recovery**:
   - If the application crashes while an item is in the `syncing` state, `OfflineSyncEngine.initialize()` automatically resets orphaned `syncing` items back to `pending` on startup.

---

## 🌐 Real Connectivity Verification

`ConnectivityService` ([lib/core/services/connectivity_service.dart](file:///d:/Projects/clean_archi_frame/lib/core/services/connectivity_service.dart)) performs **real DNS lookups** (`google.com`) to prevent false online status when connected to Wi-Fi without internet access.

---

## 🖥️ Outbox Management UI

The framework includes a built-in outbox management screen:
- **Screen**: [OutboxListScreen](file:///d:/Projects/clean_archi_frame/lib/core/offline/screens/outbox_list_screen.dart)
- **Features**:
  - Displays outbox status badges (`PENDING`, `SYNCING`, `FAILED`, `CONFLICT`).
  - Displays retry counts, backoff timing, and error logs.
  - Interactive **Retry** and **Discard** actions for failed/conflicted outbox items.

---

## 🌙 Background Sync Integration

To trigger background sync via WorkManager (Android) or BGTaskScheduler (iOS), use `BackgroundSyncService`:

```dart
// Entry point for background workers
await BackgroundSyncService.executeWithContainer(container);
```
