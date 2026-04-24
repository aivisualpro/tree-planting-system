import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/app_database.dart';
import '../../../core/sync/sync_provider.dart';

class VisitListScreen extends ConsumerWidget {
  const VisitListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visits'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(label: const Text('All'), selected: true, onSelected: (_) {}),
                FilterChip(label: const Text('Draft'), selected: false, onSelected: (_) {}),
                FilterChip(label: const Text('Pending'), selected: false, onSelected: (_) {}),
                FilterChip(label: const Text('Synced'), selected: false, onSelected: (_) {}),
                FilterChip(label: const Text('Failed'), selected: false, onSelected: (_) {}),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(syncEngineProvider).runSync();
              },
              child: ListView.builder(
                itemCount: 10, // Mock count
                itemBuilder: (context, index) {
                  return ListTile(
                    title: const Text('Activity Name'),
                    subtitle: const Text('Community/Location • 2026-04-24'),
                    trailing: const Chip(label: Text('Synced')),
                    onTap: () => context.push('/visits/detail/some-id'),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/visits/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
