import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart' show rootBundle;

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  String? markdownContent;

  @override
  void initState() {
    super.initState();
    _loadHelp();
  }

  Future<void> _loadHelp() async {
    try {
      final content = await rootBundle.loadString('assets/help/en.md');
      setState(() {
        markdownContent = content;
      });
    } catch (e) {
      setState(() {
        markdownContent = 'Help content not found.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Update Help Content',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Checking for updates...')),
              );
            },
          )
        ],
      ),
      body: markdownContent == null
          ? const Center(child: CircularProgressIndicator())
          : Markdown(data: markdownContent!),
    );
  }
}
