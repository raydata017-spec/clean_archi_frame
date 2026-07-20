import '../../../../../core/offline/offline_outbox_item.dart';
import '../../../../../core/offline/outbox_action_processor.dart';

/// Syncs offline-created profiles to the server.
///
/// Replace [_defaultApiCall] with your real Dio/API client in production.
class CreateProfileProcessor extends OutboxActionProcessor {
  /// Optional override for tests or custom API wiring.
  final Future<Map<String, dynamic>?> Function(OfflineOutboxItem item)? apiCall;

  CreateProfileProcessor({this.apiCall});

  @override
  String get actionType => 'create_profile';

  @override
  Future<Map<String, dynamic>?> process(OfflineOutboxItem item) async {
    if (apiCall != null) {
      return apiCall!(item);
    }
    return _defaultApiCall(item);
  }

  Future<Map<String, dynamic>?> _defaultApiCall(OfflineOutboxItem item) async {
    // TODO: Replace with DioClient.post('/api/profiles', data: item.payloadAsMap)
    // final response = await dioClient.post('/api/profiles', data: item.payloadAsMap);
    // if (response.statusCode == 409) throw SyncConflictException('Profile conflict');
    // if ((response.statusCode ?? 500) >= 500) throw SyncServerException('Server error');
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final clientRef = item.clientReferenceId ?? 'unknown';
    return {
      'id': 'server_$clientRef',
      'status': 'created',
    };
  }

  @override
  Future<void> onConflict(Object error, OfflineOutboxItem item) async {
    // Notify UI / mark local profile as conflicted.
  }

  @override
  Future<void> onFailure(
    Object error,
    OfflineOutboxItem item,
    int currentRetries,
  ) async {
    // Log or toast after final failure.
  }
}

/// Syncs offline profile updates to the server.
class UpdateProfileProcessor extends OutboxActionProcessor {
  final Future<Map<String, dynamic>?> Function(OfflineOutboxItem item)? apiCall;

  UpdateProfileProcessor({this.apiCall});

  @override
  String get actionType => 'update_profile';

  @override
  Future<Map<String, dynamic>?> process(OfflineOutboxItem item) async {
    if (apiCall != null) {
      return apiCall!(item);
    }
    return _defaultApiCall(item);
  }

  Future<Map<String, dynamic>?> _defaultApiCall(OfflineOutboxItem item) async {
    final payload = item.payloadAsMap;
    // TODO: Replace with real HTTP call.
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return {
      'id': payload['id']?.toString() ??
          item.clientReferenceId ??
          payload['localId']?.toString() ??
          'unknown',
      'status': 'updated',
    };
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
