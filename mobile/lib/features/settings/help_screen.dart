import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';
import 'support_screen.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  String? markdownContent;
  String _searchQuery = '';
  List<HelpSection> _sections = [];

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
        _parseMarkdown(content);
      });
    } catch (e) {
      setState(() {
        markdownContent = 'Help content not found.';
      });
    }
  }

  void _parseMarkdown(String content) {
    _sections.clear();
    final lines = content.split('\n');
    String? currentTitle;
    StringBuffer currentBody = StringBuffer();

    for (var line in lines) {
      if (line.startsWith('## ')) {
        if (currentTitle != null) {
          _sections.add(HelpSection(title: currentTitle, content: currentBody.toString().trim()));
        }
        currentTitle = line.substring(3).trim();
        currentBody = StringBuffer();
      } else if (currentTitle != null) {
        currentBody.writeln(line);
      }
    }
    if (currentTitle != null) {
      _sections.add(HelpSection(title: currentTitle, content: currentBody.toString().trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (markdownContent == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final filteredSections = _sections.where((s) => 
      s.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
      s.content.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.school),
            tooltip: 'Replay Tutorial',
            onPressed: () {
              context.push('/onboarding');
            },
          ),
          IconButton(
            icon: const Icon(Icons.support_agent),
            tooltip: 'Report an Issue',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SupportScreen()));
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search help articles...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSections.length,
              itemBuilder: (context, index) {
                final section = filteredSections[index];
                return ExpansionTile(
                  title: Text(section.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: MarkdownBody(data: section.content),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HelpSection {
  final String title;
  final String content;

  HelpSection({required this.title, required this.content});
}
