import '../../../../core/utils/enums/notification_type_enum.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.description,
    required super.createdAt,
    required super.type,
    super.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> notiData = json['notification'] is Map
        ? Map<String, dynamic>.from(json['notification'] as Map)
        : json;

    return NotificationModel(
      id: (json['id'] ?? notiData['notification_id'] ?? notiData['id'] ?? '').toString(),
      title: (json['title'] ?? notiData['title'] ?? '').toString(),
      description: (json['description'] ?? notiData['description'] ?? notiData['message'] ?? '').toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : notiData['created_at'] != null
              ? DateTime.parse(notiData['created_at'] as String)
              : DateTime.now(),
      type: NotificationType.fromString((json['type'] ?? json['notification_type'] ?? json['notificationType'] ?? notiData['type'] ?? notiData['notification_type'] ?? notiData['notificationType'] ?? '').toString()),
      isRead: (json['is_read'] ?? notiData['is_read'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'type': type.name,
      'is_read': isRead,
    };
  }

  static NotificationModel fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      createdAt: entity.createdAt,
      type: entity.type,
      isRead: entity.isRead,
    );
  }
}
