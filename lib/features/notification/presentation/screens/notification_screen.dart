import 'package:flutter/material.dart';

import '../../../../app/config/dimensions.dart';
import '../../../../app/config/localization/generated/translations.g.dart';
import '../../../../core/utils/extensions/context_extension.dart';
import '../../data/models/notification_model.dart';
import '../../domain/entities/notification_entity.dart';
import '../widgets/notification_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // Simulating data received from API
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

  late List<NotificationEntity> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications =
        _apiResponse.map<NotificationEntity>((json) => NotificationModel.fromJson(json)).toList();
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.notification.allMarkedRead),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteNotification(String id, int index, {bool isSwiped = false}) {
    if (index < 0 || index >= _notifications.length) return;

    final removedItem = _notifications[index];
    final originalIndex = index;

    setState(() {
      _notifications.removeAt(index);
    });

    _listKey.currentState?.removeItem(
      index,
      (context, animation) => NotificationCard(
        item: removedItem,
        animation: animation,
        onToggleRead: () {},
        onDelete: () {},
        onSwipeDelete: () {},
      ),
      duration: isSwiped ? Duration.zero : const Duration(milliseconds: 300),
    );

    // Show SnackBar with Undo action
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.notification.deleted),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: t.notification.undo,
          onPressed: () {
            setState(() {
              _notifications.insert(originalIndex, removedItem);
            });
            _listKey.currentState?.insertItem(
              originalIndex,
              duration: const Duration(milliseconds: 300),
            );
          },
        ),
      ),
    );
  }

  void _toggleReadStatus(int index) {
    setState(() {
      _notifications[index] = _notifications[index].copyWith(
        isRead: !_notifications[index].isRead,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: context.colors.customBackground,
      appBar: AppBar(
        title: Text(t.notification.title),
        centerTitle: false,
        actions: [
          if (_notifications.isNotEmpty) ...[
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all_rounded, size: AppSizes.iconSm),
              label: Text(t.notification.markAllRead),
              style: TextButton.styleFrom(
                foregroundColor: context.colorScheme.primary,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.fontSizeSm,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.paddingMarginSm),
          ]
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: AppSizes.iconLg * 2,
                    color: context.colorScheme.onSurface.withValues(alpha: .3),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  Text(
                    t.notification.emptyState,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colorScheme.onSurface.withValues(alpha: .5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMarginMd),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t.notification.unread(count: unreadCount),
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colorScheme.onSurface.withValues(alpha: .7),
                        ),
                      ),
                      Text(
                        t.notification.total(count: _notifications.length),
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurface.withValues(alpha: .5),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedList(
                    key: _listKey,
                    initialItemCount: _notifications.length,
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMarginMd),
                    itemBuilder: (context, index, animation) {
                      final item = _notifications[index];

                      return NotificationCard(
                        item: item,
                        animation: animation,
                        onToggleRead: () => _toggleReadStatus(index),
                        onDelete: () => _deleteNotification(item.id, index, isSwiped: false),
                        onSwipeDelete: () => _deleteNotification(item.id, index, isSwiped: true),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
