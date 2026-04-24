import 'package:flutter/material.dart';
import 'language_picker.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: const [
          ListTile(
            title: Text('Language'),
            trailing: LanguagePicker(),
          ),
        ],
      ),
    );
  }
}
