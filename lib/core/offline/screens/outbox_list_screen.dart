import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/config/assets.dart';
import '../../../app/config/dimensions.dart';
import '../../../shared/widgets/app_empty_widget.dart';
import '../../utils/enums/outbox_status_enum.dart';
import '../../utils/extensions/context_extension.dart';
import '../../di/offline_di.dart';
import '../../di/outbox_di.dart';
import '../widgets/outbox_item_card.dart';

class OutboxListScreen extends ConsumerWidget {
  const OutboxListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outboxItemsAsync = ref.watch(outboxListProvider);

    return Scaffold(
      backgroundColor: context.colors.customBackground,
      appBar: AppBar(
        title: const Text('Offline Outbox'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Sync Now',
            icon: const Icon(Icons.sync_rounded),
            onPressed: () {
              ref.read(offlineSyncEngineProvider).triggerSync();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Triggered Outbox Sync...'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: outboxItemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const AppEmptyWidget(
              imageUrl: Assets.emptyBoxPng,
              title: 'No pending outbox items',
            );
          }

          final pendingCount = items.where((i) => i.status == OutboxStatusEnum.pending).length;
          final syncingCount = items.where((i) => i.status == OutboxStatusEnum.syncing).length;
          final failedCount = items.where((i) => i.status == OutboxStatusEnum.failed || i.status == OutboxStatusEnum.conflict).length;

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
                        color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      'Syncing: $syncingCount • Failed: $failedCount',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingFromScreenEdge),
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
    );
  }
}
