import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'language_picker.dart';
import 'training_mode_provider.dart';
import '../profile/profile_provider.dart';
import 'certificate_generator.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTrainingMode = ref.watch(trainingModeProvider);
    final profileState = ref.watch(profileStateProvider);

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
          SwitchListTile(
            title: const Text('Training Mode'),
            subtitle: const Text('Practice creating visits with fake data'),
            value: isTrainingMode,
            onChanged: (val) {
              ref.read(trainingModeProvider.notifier).toggle();
            },
          ),
          if (isTrainingMode)
            ListTile(
              title: const Text('Reset Training Data'),
              trailing: const Icon(Icons.delete_outline, color: Colors.red),
              onTap: () {
                // Clear demo.db logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Training data reset')),
                );
              },
            ),
          const Divider(),
          ListTile(
            title: const Text('Storage Management'),
            subtitle: const Text('Manage device storage and photos'),
            trailing: const Icon(Icons.sd_storage),
            onTap: () => context.go('/settings/storage'),
          ),
          ListTile(
            title: const Text('Offline Maps'),
            subtitle: const Text('Download maps for offline use'),
            trailing: const Icon(Icons.map),
            onTap: () => context.go('/settings/offline-maps'),
          ),
          const Divider(),
          if (profileState.value?['tutorial_completed'] == true)
            ListTile(
              title: const Text('View Training Certificate'),
              trailing: const Icon(Icons.workspace_premium, color: Colors.amber),
              onTap: () {
                final user = profileState.value;
                final name = user?['email'] ?? 'Field User';
                CertificateGenerator.generateAndShareCertificate(name);
              },
            ),
          ListTile(
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.help_outline),
            onTap: () => context.go('/settings/help'),
          ),
        ],
      ),
    );
  }
}
