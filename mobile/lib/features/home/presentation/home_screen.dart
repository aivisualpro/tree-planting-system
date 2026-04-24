import 'package:flutter/material.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../../core/widgets/sync_status_chip.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tree Planting')),
      body: Column(
        children: [
          const OfflineBanner(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: SyncStatusChip(),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildCard('New Visit'),
                _buildCard('View Visits'),
                _buildCard('Drafts'),
                _buildCard('Sync Now'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title) {
    return Card(
      child: InkWell(
        onTap: () {},
        child: Center(child: Text(title)),
      ),
    );
  }
}
