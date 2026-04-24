import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'language_picker.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Language'),
            trailing: LanguagePicker(),
          ),
          ListTile(
            title: const Text('Notifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/notifications'),
          ),
        ],
      ),
    );
  }
}
