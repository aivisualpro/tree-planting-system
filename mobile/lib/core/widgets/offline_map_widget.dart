import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';

class OfflineMapWidget extends StatelessWidget {
  final LatLng initialCenter;
  final double initialZoom;
  final bool interactive;

  const OfflineMapWidget({
    super.key,
    required this.initialCenter,
    this.initialZoom = 13.0,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          tileProvider: const FMTCStore('offline_maps').getTileProvider(),
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: initialCenter,
              width: 40,
              height: 40,
              child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
            ),
          ],
        ),
      ],
    );
  }
}
