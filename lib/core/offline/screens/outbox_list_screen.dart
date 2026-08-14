import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/config/assets.dart';
import '../../../app/config/dimensions.dart';
import '../../../shared/widgets/app_empty_widget.dart';
import '../../utils/enums/outbox_status_enum.dart';
import '../../utils/extensions/context_extension.dart';
import '../../services/connectivity_service.dart';
import '../../di/offline_di.dart';
import '../../di/outbox_di.dart';
import '../providers/sync_wifi_only_provider.dart';
import '../widgets/outbox_item_card.dart';

class OutboxListScreen extends ConsumerWidget {
  const OutboxListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outboxItemsAsync = ref.watch(outboxListProvider);
    final syncWifiOnly = ref.watch(syncWifiOnlyProvider);

    return Scaffold(
      backgroundColor: context.colors.customBackground,
      appBar: AppBar(
        title: const Text('Offline Outbox'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Sync Now',
            icon: const Icon(Icons.sync_rounded),
            onPressed: () async {
              final connectivity = ref.read(connectivityServiceProvider);
              final hasInternet = await connectivity.hasInternet();
              if (!hasInternet) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cannot sync: No internet connection.'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                return;
              }

              if (syncWifiOnly) {
                final isWifi = await connectivity.isWifiConnected();
                if (!isWifi) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cannot sync: "Sync on Wi-Fi only" is enabled. Connect to Wi-Fi or turn off the setting.'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                  return;
                }
              }

              ref.read(offlineSyncEngineProvider).triggerSync();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Triggered Outbox Sync...'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingFromScreenEdge,
              vertical: AppSizes.paddingMarginSm,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMarginMd,
                  vertical: AppSizes.paddingMarginXs / 2,
                ),
                leading: CircleAvatar(
                  backgroundColor: (syncWifiOnly
                          ? context.colorScheme.primary
                          : context.colorScheme.onSurfaceVariant)
                      .withValues(alpha: 0.1),
                  child: Icon(
                    Icons.wifi_rounded,
                    color: syncWifiOnly
                        ? context.colorScheme.primary
                        : context.colorScheme.onSurfaceVariant,
                    size: AppSizes.iconMd,
                  ),
                ),
                title: Text(
                  'Sync on Wi-Fi only',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Only upload pending actions when connected to Wi-Fi',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Switch(
                  value: syncWifiOnly,
                  activeThumbColor: context.colorScheme.primary,
                  onChanged: (value) =>
                      ref.read(syncWifiOnlyProvider.notifier).toggle(value),
                ),
                onTap: () =>
                    ref.read(syncWifiOnlyProvider.notifier).toggle(!syncWifiOnly),
              ),
            ),
          ),
          Expanded(
            child: outboxItemsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const AppEmptyWidget(
                    imageUrl: Assets.emptyBoxPng,
                    title: 'No pending outbox items',
                  );
                }

                final pendingCount = items
                    .where((i) => i.status == OutboxStatusEnum.pending)
                    .length;
                final syncingCount = items
                    .where((i) => i.status == OutboxStatusEnum.syncing)
                    .length;
                final failedCount = items
                    .where((i) =>
                        i.status == OutboxStatusEnum.failed ||
                        i.status == OutboxStatusEnum.conflict)
                    .length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingFromScreenEdge,
                        vertical: AppSizes.paddingMarginSm,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pending ($pendingCount)',
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            'Syncing: $syncingCount • Failed: $failedCount',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingFromScreenEdge),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return OutboxItemCard(item: items[index]);
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) {
                log(error.toString(), stackTrace: stack);
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingMarginLg),
                    child: Text(
                      'Failed to load outbox: $error',
                      style: TextStyle(color: context.colorScheme.error),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
