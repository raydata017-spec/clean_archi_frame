import 'package:flutter/material.dart';

import '../../../../app/config/dimensions.dart';
import '../../../../app/config/localization/generated/translations.g.dart';
import '../../../../core/utils/enums/notification_action_enum.dart';
import '../../../../core/utils/enums/notification_type_enum.dart';
import '../../../../core/utils/extensions/context_extension.dart';
import '../../../../shared/widgets/app_selection_bottom_sheet.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationCard extends StatelessWidget {
  final NotificationEntity item;
  final Animation<double> animation;
  final VoidCallback onToggleRead;
  final VoidCallback onDelete;
  final VoidCallback onSwipeDelete;

  const NotificationCard({
    super.key,
    required this.item,
    required this.animation,
    required this.onToggleRead,
    required this.onDelete,
    required this.onSwipeDelete,
  });

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.security:
        return Icons.shield_outlined;
      case NotificationType.system:
        return Icons.system_update_alt_rounded;
      case NotificationType.analytics:
        return Icons.analytics_outlined;
      case NotificationType.general:
      default:
        return Icons.notifications_none_rounded;
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return t.notification.minutesAgo(minutes: diff.inMinutes);
    } else if (diff.inHours < 24) {
      return t.notification.hoursAgo(hours: diff.inHours);
    } else {
      return t.notification.daysAgo(days: diff.inDays);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      // sizeFactor: animation,
      position: animation.drive(
        Tween<Offset>(
          begin: const Offset(-1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOut)),
      ),
      child: Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          onSwipeDelete();
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSizes.paddingMarginLg),
          color: context.colorScheme.error.withValues(alpha: 0.05),
          child: Icon(
            Icons.delete_outline_rounded,
            color: context.colorScheme.error,
            size: AppSizes.iconMd,
          ),
        ),
        child: ListTile(
          titleAlignment: ListTileTitleAlignment.top,
          contentPadding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMarginXs - 2),
          onTap: onToggleRead,
          onLongPress: () async {
            final action = await AppSelectionBottomSheet.show<NotificationActionEnum>(
              context: context,
              title: t.notification.actionsTitle,
              items: [
                SelectionItem(
                  value: NotificationActionEnum.toggleRead,
                  label: item.isRead ? t.notification.markUnread : t.notification.markRead,
                  leading: Icon(
                    item.isRead ? Icons.mark_chat_unread_outlined : Icons.mark_chat_read_outlined,
                    color: context.colorScheme.onSurface.withValues(alpha: .7),
                  ),
                ),
                SelectionItem(
                  value: NotificationActionEnum.delete,
                  label: t.notification.delete,
                  leading: Icon(
                    Icons.delete_outline_rounded,
                    color: context.colorScheme.error,
                  ),
                ),
              ],
            );

            if (action == NotificationActionEnum.toggleRead) {
              onToggleRead();
            } else if (action == NotificationActionEnum.delete) {
              onDelete();
            }
          },
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMarginXs),
            child: Icon(
              _getIconForType(item.type),
              color: item.isRead
                  ? context.colorScheme.onSurface.withValues(alpha: .4)
                  : context.colorScheme.primary,
              size: AppSizes.iconMd,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                    color: item.isRead
                        ? context.colorScheme.onSurface.withValues(alpha: .9)
                        : context.colorScheme.primary,
                  ),
                ),
              ),
              Text(
                _formatTime(item.createdAt),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: .4),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: AppSizes.paddingMarginXs),
            child: Text(
              item.description,
              style: context.textTheme.bodyMedium?.copyWith(
                color: item.isRead
                    ? context.colorScheme.onSurface.withValues(alpha: .9)
                    : context.colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
