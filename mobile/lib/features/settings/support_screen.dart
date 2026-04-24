import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  final _controller = TextEditingController();
  File? _screenshot;
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _screenshot = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_controller.text.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final info = await PackageInfo.fromPlatform();
      final user = Supabase.instance.client.auth.currentUser;
      
      final payload = {
        'issue_description': _controller.text,
        'app_version': info.version,
        'user_id': user?.id,
        'has_screenshot': _screenshot != null,
      };

      // Push directly to Supabase for now; offline outbox integration is future work
      await Supabase.instance.client.from('notification_events').insert({
        'type': 'support_request',
        'payload': payload,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Issue reported successfully.')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report an Issue')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Describe the problem you are facing:'),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'I cannot sync my visits...',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: Text(_screenshot == null ? 'Attach Screenshot (Optional)' : 'Screenshot Attached'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting ? const CircularProgressIndicator() : const Text('Submit Report'),
            ),
          ],
        ),
      ),
    );
  }
}
