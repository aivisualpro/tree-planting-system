import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DraftsScreen extends ConsumerWidget {
  const DraftsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drafts'),
      ),
      body: ListView.builder(
        itemCount: 3, // Mock count
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key('draft_$index'),
            background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
            onDismissed: (direction) {
              // Delete draft
            },
            child: ListTile(
              title: const Text('Draft Activity'),
              subtitle: const Text('Last edited: 2 hours ago'),
              onTap: () => context.push('/visits/create'), // Resume editing
            ),
          );
        },
      ),
    );
  }
}
