import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/notification_entity.dart';
import '../../data/models/notification_model.dart';

class NotificationNotifier extends Notifier<List<NotificationEntity>> {
  @override
  List<NotificationEntity> build() {
    return const [];
  }

  void setNotifications(List<NotificationEntity> list) {
    state = list;
  }

  void addNewNotification(NotificationEntity notification) {
    if (state.any((n) => n.id == notification.id)) return;
    state = [notification, ...state];
  }

  void markNotiAsReadById(List<String> ids) {
    state = [
      for (final noti in state)
        if (ids.contains(noti.id)) noti.copyWith(isRead: true) else noti,
    ];
  }

  void toggleReadStatus(String id) {
    state = [
      for (final noti in state)
        if (noti.id == id) noti.copyWith(isRead: !noti.isRead) else noti,
    ];
  }

  void markAllAsRead() {
    state = state.map((noti) => noti.copyWith(isRead: true)).toList();
  }

  void deleteNotification(String id) {
    state = state.where((noti) => noti.id != id).toList();
  }

  void addNotificationFromMap(Map<String, dynamic> data) {
    final noti = NotificationModel.fromJson(data);
    addNewNotification(noti);
  }
}

class NotificationStates {
  NotificationStates._();

  static final notificationProvider =
      NotifierProvider<NotificationNotifier, List<NotificationEntity>>(() {
    return NotificationNotifier();
  });

  static final unreadNotificationCountProvider = Provider<int>((ref) {
    final notifications = ref.watch(notificationProvider);
    return notifications.where((n) => !n.isRead).length;
  });
}
