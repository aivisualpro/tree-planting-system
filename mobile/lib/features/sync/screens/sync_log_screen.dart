import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncLogScreen extends ConsumerWidget {
  const SyncLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Retry all failed',
            onPressed: () {
              // Retry logic
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: 10, // Mock count
        itemBuilder: (context, index) {
          final isFailed = index % 3 == 0;
          return ListTile(
            leading: Icon(
              isFailed ? Icons.error : Icons.check_circle,
              color: isFailed ? Colors.red : Colors.green,
            ),
            title: Text(isFailed ? 'Failed: Network Error' : 'Synced Successfully'),
            subtitle: Text('Event ID: 12345 • Attempt: ${isFailed ? 3 : 1}'),
          );
        },
      ),
    );
  }
}
