import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OfflineMapsScreen extends ConsumerStatefulWidget {
  const OfflineMapsScreen({super.key});

  @override
  ConsumerState<OfflineMapsScreen> createState() => _OfflineMapsScreenState();
}

class _OfflineMapsScreenState extends ConsumerState<OfflineMapsScreen> {
  final store = const FMTCStore('offline_maps');
  bool isDownloading = false;
  double progress = 0.0;
  String? currentRegion;

  // Mock list of assigned countries
  final List<Map<String, dynamic>> assignedCountries = [
    {
      'name': 'Tanzania',
      'south': -11.7,
      'west': 29.3,
      'north': -1.0,
      'east': 40.4,
    },
    {
      'name': 'Kenya',
      'south': -4.7,
      'west': 33.9,
      'north': 4.6,
      'east': 41.9,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Maps')),
      body: Column(
        children: [
          if (isDownloading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Downloading $currentRegion...'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 8),
                  Text('${(progress * 100).toStringAsFixed(1)}%'),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: assignedCountries.length,
              itemBuilder: (context, index) {
                final country = assignedCountries[index];
                return ListTile(
                  title: Text(country['name']),
                  subtitle: const Text('Zoom 8-15 (~150MB)'),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: isDownloading
                        ? null
                        : () => _downloadRegion(country),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton(
              onPressed: _clearCache,
              child: const Text('Clear All Offline Maps'),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _downloadRegion(Map<String, dynamic> country) async {
    setState(() {
      isDownloading = true;
      progress = 0.0;
      currentRegion = country['name'];
    });

    final bounds = LatLngBounds(
      LatLng(country['south'] as double, country['west'] as double),
      LatLng(country['north'] as double, country['east'] as double),
    );

    final region = RectangleRegion(bounds);
    final downloadableRegion = region.toDownloadable(
      minZoom: 8,
      maxZoom: 15,
      options: TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      ),
    );

    try {
      final result = store.download.startForeground(region: downloadableRegion);
      await for (final progressEvent in result.downloadProgress) {
        setState(() {
          progress = progressEvent.percentageProgress / 100.0;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${country['name']} map downloaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isDownloading = false;
        });
      }
    }
  }

  Future<void> _clearCache() async {
    await store.manage.reset();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offline maps cleared')),
      );
    }
  }
}
