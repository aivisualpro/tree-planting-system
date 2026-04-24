import 'package:flutter/material.dart';

class SyncStatusChip extends StatelessWidget {
  const SyncStatusChip({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, hardcode "Synced" as requested in deliverable
    return const Chip(
      label: Text('Synced'),
      backgroundColor: Colors.green,
      labelStyle: TextStyle(color: Colors.white),
    );
  }
}
