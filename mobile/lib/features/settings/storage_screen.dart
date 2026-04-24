import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StorageScreen extends ConsumerWidget {
  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storage Management')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            title: Text('App Data'),
            trailing: Text('12 MB'),
          ),
          const ListTile(
            title: Text('Photos Pending Upload'),
            trailing: Text('45 MB'),
          ),
          const ListTile(
            title: Text('Photos Synced'),
            trailing: Text('120 MB'),
          ),
          const ListTile(
            title: Text('Offline Maps'),
            trailing: Text('150 MB'),
          ),
          const Divider(),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Clear Synced Photos'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Clear Offline Maps'),
          ),
        ],
      ),
    );
  }
}
