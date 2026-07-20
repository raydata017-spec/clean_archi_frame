import 'dart:convert';

import '../utils/enums/outbox_status_enum.dart' show OutboxStatusEnum;

class OfflineOutboxItem {
  final int id;
  final String url;
  final String method;
  final String actionType;
  final String payload;
  final int retryCount;
  final String? clientReferenceId;
  final int maxRetries;
  final OutboxStatusEnum status;
  final String? lastError;
  final DateTime? nextRetryAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OfflineOutboxItem({
    required this.id,
    required this.url,
    required this.method,
    required this.actionType,
    required this.payload,
    required this.retryCount,
    this.clientReferenceId,
    required this.maxRetries,
    required this.status,
    this.lastError,
    this.nextRetryAt,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> get payloadAsMap =>
      jsonDecode(payload) as Map<String, dynamic>;

  bool get hasRemainingRetries => retryCount < maxRetries;

  bool get isReadyToSync {
    if (!hasRemainingRetries) return false;
    if (nextRetryAt == null) return true;
    return !nextRetryAt!.isAfter(DateTime.now());
  }

  factory OfflineOutboxItem.create({
    required int id,
    required String url,
    required String method,
    required String actionType,
    required Map<String, dynamic> payloadMap,
    required int retryCount,
    String? clientReferenceId,
    required int maxRetries,
    required OutboxStatusEnum status,
    String? lastError,
    DateTime? nextRetryAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) {
    return OfflineOutboxItem(
      id: id,
      url: url,
      method: method,
      actionType: actionType,
      payload: jsonEncode(payloadMap),
      retryCount: retryCount,
      clientReferenceId: clientReferenceId,
      maxRetries: maxRetries,
      status: status,
      lastError: lastError,
      nextRetryAt: nextRetryAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Parameters for enqueueing a new offline write action.
class OutboxEnqueueParams {
  final String url;
  final String method;
  final String actionType;
  final Map<String, dynamic> payload;
  final String? clientReferenceId;
  final int maxRetries;

  const OutboxEnqueueParams({
    required this.url,
    required this.method,
    required this.actionType,
    required this.payload,
    this.clientReferenceId,
    this.maxRetries = 3,
  });
}
