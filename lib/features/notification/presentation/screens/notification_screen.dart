import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../app/config/assets.dart';
import '../../../../app/config/dimensions.dart';
import '../../../../app/config/localization/generated/translations.g.dart';
import '../../../../core/utils/extensions/context_extension.dart';
import '../../../../core/utils/enums/notification_type_enum.dart';
import '../../domain/entities/notification_entity.dart';
import '../../../../shared/widgets/app_empty_widget.dart';
import '../widgets/notification_card.dart';
import '../providers/notification_provider.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  final List<NotificationEntity> _skeletonItems = [
    NotificationEntity(
      id: 's1',
      title: 'Security Alert',
      description: 'New login detected from Chrome on Windows 11.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      type: NotificationType.security,
      isRead: false,
    ),
    NotificationEntity(
      id: 's2',
      title: 'System Update Alert',
      description:
          'Your system has been updated to the latest version with new features and improvements.',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      type: NotificationType.system,
      isRead: false,
    ),
    NotificationEntity(
      id: 's3',
      title: 'General Notification',
      description:
          'General system announcements message details are rendered here in the skeleton card.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.general,
      isRead: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  void _markAllAsRead() {
    ref.read(NotificationStates.notificationProvider.notifier).markAllAsRead();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.notification.allMarkedRead),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteNotification(String id, int index, {bool isSwiped = false}) {
    final notificationsAsync = ref.read(NotificationStates.notificationProvider);
    final notifications = notificationsAsync.value ?? [];
    if (index < 0 || index >= notifications.length) return;

    final removedItem = notifications[index];

    ref.read(NotificationStates.notificationProvider.notifier).deleteNotification(id);

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
    final controller = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.notification.deleted),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: t.notification.undo,
          onPressed: () {
            ref
                .read(NotificationStates.notificationProvider.notifier)
                .addNewNotification(removedItem);
            _listKey.currentState?.insertItem(
              0,
              duration: const Duration(milliseconds: 300),
            );
          },
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        controller.close();
      }
    });
  }

  void _toggleReadStatus(String id) {
    ref.read(NotificationStates.notificationProvider.notifier).toggleReadStatus(id);
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(NotificationStates.notificationProvider);
    final unreadCount = ref.watch(NotificationStates.unreadNotificationCountProvider);

    return Scaffold(
      backgroundColor: context.colors.customBackground,
      appBar: AppBar(
        title: Text(t.notification.title),
        centerTitle: false,
        actions: [
          notificationsAsync.maybeWhen(
            data: (notifications) {
              if (notifications.isEmpty) return const SizedBox();
              return Row(
                children: [
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
                ],
              );
            },
            orElse: () => const SizedBox(),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return AppEmptyWidget(
              imageUrl: Assets.emptyBoxPng,
              title: t.notification.emptyState,
            );
          }

          return Column(
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
                      t.notification.total(count: notifications.length),
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
                  initialItemCount: notifications.length,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMarginMd),
                  itemBuilder: (context, index, animation) {
                    if (index >= notifications.length) return const SizedBox();
                    final item = notifications[index];

                    return NotificationCard(
                      item: item,
                      animation: animation,
                      onToggleRead: () => _toggleReadStatus(item.id),
                      onDelete: () {
                        final liveIndex = notifications.indexWhere((n) => n.id == item.id);
                        if (liveIndex != -1) {
                          _deleteNotification(
                            item.id,
                            liveIndex,
                            isSwiped: false,
                          );
                        }
                      },
                      onSwipeDelete: () => _deleteNotification(item.id, index, isSwiped: true),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => Skeletonizer(
          enabled: true,
          child: ListView.builder(
            itemCount: _skeletonItems.length,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMarginMd),
            itemBuilder: (context, index) {
              return NotificationCard(
                item: _skeletonItems[index],
                animation: const AlwaysStoppedAnimation(1.0),
                onToggleRead: () {},
                onDelete: () {},
                onSwipeDelete: () {},
              );
            },
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMarginLg),
            child: Text(
              'Error loading notifications: $error',
              style: TextStyle(color: context.colorScheme.error),
            ),
          ),
        ),
      ),
    );
  }
}
