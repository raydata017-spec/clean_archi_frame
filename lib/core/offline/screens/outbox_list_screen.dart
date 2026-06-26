import 'dart:developer';

import '../../di/outbox_di.dart';
import '../../utils/enums/outbox_status_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OutboxListScreen extends ConsumerWidget {
  const OutboxListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outboxItems = ref.watch(outboxListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Outbox'),
      ),
      body: outboxItems.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('No offline outbox items found.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              final statusName = item.status >= 0 && item.status < OutboxStatusEnum.values.length ? OutboxStatusEnum.values[item.status].name : 'unknown';

              return Card(
                child: ListTile(
                  title: Text(item.actionType),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('URL: ${item.url}'),
                      const SizedBox(height: 4),
                      Text('Method: ${item.method.toUpperCase()}'),
                      const SizedBox(height: 4),
                      Text('Status: $statusName'),
                      if (item.lastError != null && item.lastError!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Last error: ${item.lastError}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Retries: ${item.retryCount}'),
                      const SizedBox(height: 4),
                      Text(item.createdAt.toLocal().toIso8601String().split('T').first),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          log(error.toString());
          log(stack.toString());
          return Center(
            child: Text('Failed to load outbox: $error'),
          );
        },
      ),
    );
  }
}
