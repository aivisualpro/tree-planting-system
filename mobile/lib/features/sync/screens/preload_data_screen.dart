import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PreloadDataScreen extends ConsumerStatefulWidget {
  const PreloadDataScreen({super.key});

  @override
  ConsumerState<PreloadDataScreen> createState() => _PreloadDataScreenState();
}

class _PreloadDataScreenState extends ConsumerState<PreloadDataScreen> {
  double progress = 0.0;
  bool isFailed = false;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    setState(() {
      progress = 0.0;
      isFailed = false;
    });

    try {
      // Mocking the download process
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          setState(() {
            progress = i / 10.0;
          });
        }
      }
      
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isFailed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_download, size: 64, color: Colors.green),
              const SizedBox(height: 24),
              const Text(
                'Downloading essential data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('${(progress * 15).toStringAsFixed(1)}MB / 15MB'),
              const SizedBox(height: 24),
              LinearProgressIndicator(value: progress),
              if (isFailed) ...[
                const SizedBox(height: 24),
                const Text(
                  'Download failed. You cannot use the app without reference data.',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _startDownload,
                  child: const Text('Retry'),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
