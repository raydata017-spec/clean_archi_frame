import '../../../../core/utils/enums/notification_type_enum.dart';

class NotificationEntity {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final NotificationType type;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.type,
    this.isRead = false,
  });

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    NotificationType? type,
    bool? isRead,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}
