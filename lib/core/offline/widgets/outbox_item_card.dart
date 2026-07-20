import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/config/dimensions.dart';
import '../../utils/enums/outbox_status_enum.dart';
import '../../utils/extensions/context_extension.dart';
import '../../../shared/widgets/app_selection_bottom_sheet.dart';
import '../offline_outbox_item.dart';
import '../../di/offline_di.dart';
import '../../di/outbox_di.dart';

enum OutboxItemAction { retry, delete }

class OutboxItemCard extends ConsumerWidget {
  final OfflineOutboxItem item;

  const OutboxItemCard({
    super.key,
    required this.item,
  });

  IconData _getMethodIcon(String method) {
    switch (method.toUpperCase()) {
      case 'POST':
        return Icons.add_circle_outline_rounded;
      case 'PUT':
      case 'PATCH':
        return Icons.edit_outlined;
      case 'DELETE':
        return Icons.delete_outline_rounded;
      default:
        return Icons.swap_horiz_rounded;
    }
  }

  Color _getStatusColor(BuildContext context, OutboxStatusEnum status) {
    switch (status) {
      case OutboxStatusEnum.pending:
        return context.colorScheme.primary;
      case OutboxStatusEnum.syncing:
        return context.colorScheme.secondary;
      case OutboxStatusEnum.failed:
      case OutboxStatusEnum.conflict:
        return context.colorScheme.error;
      case OutboxStatusEnum.completed:
        return context.colorScheme.tertiary;
      case OutboxStatusEnum.unknow:
        return context.colorScheme.onSurfaceVariant;
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _getStatusColor(context, item.status);
    final iconData = _getMethodIcon(item.method);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMarginSm),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMarginMd,
          vertical: AppSizes.paddingMarginXs,
        ),
        onLongPress: () => _showActionBottomSheet(context, ref),
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.1),
          child: Icon(
            iconData,
            color: statusColor,
            size: AppSizes.iconMd,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.actionType,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSizes.paddingMarginSm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMarginSm,
                vertical: AppSizes.paddingMarginXs / 2,
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
              ),
              child: Text(
                item.status.name.toUpperCase(),
                style: context.textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.paddingMarginXs),
            Text(
              '${item.method.toUpperCase()} ${item.url}',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSizes.paddingMarginXs / 2),
            Row(
              children: [
                Text(
                  'Retries: ${item.retryCount}/${item.maxRetries}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMarginSm),
                Text(
                  '• ${_formatTime(item.createdAt)}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            if (item.lastError != null && item.lastError!.isNotEmpty) ...[
              const SizedBox(height: AppSizes.paddingMarginXs),
              Text(
                item.lastError!,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.error,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.more_vert_rounded,
            color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          onPressed: () => _showActionBottomSheet(context, ref),
        ),
      ),
    );
  }

  Future<void> _showActionBottomSheet(BuildContext context, WidgetRef ref) async {
    final selectedAction = await AppSelectionBottomSheet.show<OutboxItemAction>(
      context: context,
      title: 'Outbox Action',
      items: [
        SelectionItem(
          value: OutboxItemAction.retry,
          label: 'Retry Sync',
          leading: Icon(
            Icons.refresh_rounded,
            color: context.colorScheme.primary,
          ),
        ),
        SelectionItem(
          value: OutboxItemAction.delete,
          label: 'Delete Action',
          leading: Icon(
            Icons.delete_outline_rounded,
            color: context.colorScheme.error,
          ),
        ),
      ],
    );

    if (selectedAction == OutboxItemAction.retry) {
      await ref.read(offlineOutboxRepositoryProvider).retryOutboxItem(item.id);
      ref.read(offlineSyncEngineProvider).triggerSync();
    } else if (selectedAction == OutboxItemAction.delete) {
      await ref.read(offlineOutboxRepositoryProvider).deleteOutboxItem(item.id);
    }
  }
}
