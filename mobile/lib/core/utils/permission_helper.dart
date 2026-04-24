import 'package:flutter/material.dart';

class PermissionHelper {
  static Future<bool> requestCamera(BuildContext context) async {
    return await _showExplanationDialog(
      context,
      'Camera Access Required',
      'We need your camera to capture visit photos. These photos are used to verify tree planting progress and health. No photos are taken without your explicit action.',
    );
  }

  static Future<bool> requestLocation(BuildContext context) async {
    return await _showExplanationDialog(
      context,
      'Location Access Required',
      'We need your location while you are using the app to accurately tag the GPS coordinates of your planting sites. We only use your location in the foreground during an active visit.',
    );
  }

  static Future<bool> requestNotifications(BuildContext context) async {
    return await _showExplanationDialog(
      context,
      'Stay Updated',
      'Enable notifications to receive important alerts about sync status, shift updates, and emergency broadcasts. You can change this later in settings.',
    );
  }

  static Future<bool> _showExplanationDialog(BuildContext context, String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () {
              // In a real implementation, you would call the OS permission dialog here.
              // Example: Permission.camera.request();
              Navigator.of(ctx).pop(true);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
