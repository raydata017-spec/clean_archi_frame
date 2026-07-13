import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/notification_entity.dart';
import '../../data/models/notification_model.dart';

class NotificationNotifier extends AsyncNotifier<List<NotificationEntity>> {
  final List<Map<String, dynamic>> _apiResponse = [
    {
      'id': '1',
      'title': 'Security Alert',
      'description': 'New login detected from Chrome on Windows 11.',
      'created_at': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
      'type': 'security',
      'is_read': false,
    },
    {
      'id': '2',
      'title': 'System Update',
      'description': 'Clean Architecture Framework v1.1.0 is now available.',
      'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      'type': 'system',
      'is_read': false,
    },
    {
      'id': '3',
      'title': 'Report Generated',
      'description': 'Monthly active user analytics report is ready to view.',
      'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'type': 'analytics',
      'is_read': true,
    },
    {
      'id': '4',
      'title': 'Welcome onboard',
      'description': 'Explore the starter kit and check out documentation.',
      'created_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      'type': 'general',
      'is_read': true,
    },
  ];

  @override
  Future<List<NotificationEntity>> build() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    return _apiResponse
        .map<NotificationEntity>((json) => NotificationModel.fromJson(json))
        .toList();
  }

  void setNotifications(List<NotificationEntity> list) {
    state = AsyncValue.data(list);
  }

  void addNewNotification(NotificationEntity notification) {
    state.whenData((notifications) {
      if (notifications.any((n) => n.id == notification.id)) return;
      state = AsyncValue.data([notification, ...notifications]);
    });
  }

  void markNotiAsReadById(List<String> ids) {
    state.whenData((notifications) {
      state = AsyncValue.data([
        for (final noti in notifications)
          if (ids.contains(noti.id)) noti.copyWith(isRead: true) else noti,
      ]);
    });
  }

  void toggleReadStatus(String id) {
    state.whenData((notifications) {
      state = AsyncValue.data([
        for (final noti in notifications)
          if (noti.id == id) noti.copyWith(isRead: !noti.isRead) else noti,
      ]);
    });
  }

  void markAllAsRead() {
    state.whenData((notifications) {
      state = AsyncValue.data(
        notifications.map((noti) => noti.copyWith(isRead: true)).toList(),
      );
    });
  }

  void deleteNotification(String id) {
    state.whenData((notifications) {
      state = AsyncValue.data(
        notifications.where((noti) => noti.id != id).toList(),
      );
    });
  }

  void addNotificationFromMap(Map<String, dynamic> data) {
    final noti = NotificationModel.fromJson(data);
    addNewNotification(noti);
  }
}

class NotificationStates {
  NotificationStates._();

  static final notificationProvider =
      AsyncNotifierProvider<NotificationNotifier, List<NotificationEntity>>(() {
    return NotificationNotifier();
  });

  static final unreadNotificationCountProvider = Provider<int>((ref) {
    final notificationsAsync = ref.watch(notificationProvider);
    return notificationsAsync.maybeWhen(
      data: (notifications) => notifications.where((n) => !n.isRead).length,
      orElse: () => 0,
    );
  });
}
