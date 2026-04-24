import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/widgets/offline_map_widget.dart';

class VisitDetailScreen extends ConsumerWidget {
  final String visitId;
  const VisitDetailScreen({super.key, required this.visitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visit Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sync Status: Synced', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Photos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Container(width: 100, color: Colors.grey[300], margin: const EdgeInsets.only(right: 8), child: const Icon(Icons.image)),
                  Container(width: 100, color: Colors.grey[300], margin: const EdgeInsets.only(right: 8), child: const Icon(Icons.image)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('GPS Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: OfflineMapWidget(
                  initialCenter: LatLng(-6.173, 35.741), // Example coordinates for Tanzania
                  initialZoom: 10.0,
                  interactive: false,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Signature', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(height: 100, width: double.infinity, color: Colors.grey[300], child: const Center(child: Text('Signature Image'))),
          ],
        ),
      ),
    );
  }
}
