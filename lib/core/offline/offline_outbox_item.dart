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
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> get payloadAsMap => jsonDecode(payload);

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
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
