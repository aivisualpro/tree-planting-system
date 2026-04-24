import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolledToBottom = false;
  bool _hasAccepted = false;
  String _selectedLanguage = 'en';

  final String _termsText = '''
Privacy Policy & Terms of Service

Effective Date: April 24, 2026

1. Acceptable Use
You agree to use the platform only for lawful purposes directly related to field operations, tree-planting, and environmental monitoring.

2. User Responsibilities
You are responsible for ensuring that the data you input (including GPS coordinates, photos, and tree counts) is accurate. You must obtain necessary consent before photographing individuals, especially minors.

3. Privacy & Data Collection
We collect location, photos, device ID, and contact details for operational reporting and app stability. Third parties (Supabase, Vercel, Sentry, FCM) assist us. You have the right to access, export, and delete your data under GDPR, Tanzania DPA, and Malawi DPA.

(Scroll to the bottom to accept)
''' * 10; // Multiply to make it scrollable

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
      if (!_isScrolledToBottom) {
        setState(() {
          _isScrolledToBottom = true;
        });
      }
    }
  }

  Future<void> _submit() async {
    // In a real app, you would update the profile via Riverpod/Supabase
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('profiles').update({
          'accepted_terms_version': '1.0.0',
          'accepted_terms_timestamp': DateTime.now().toIso8601String(),
        }).eq('id', user.id);
      }
    } catch (e) {
      debugPrint('Error updating terms acceptance: $e');
    }
    if (mounted) {
      context.go('/preload');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Privacy'),
        actions: [
          DropdownButton<String>(
            value: _selectedLanguage,
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'sw', child: Text('Swahili')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedLanguage = val);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Text(_termsText),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _hasAccepted,
                      onChanged: _isScrolledToBottom
                          ? (val) => setState(() => _hasAccepted = val ?? false)
                          : null,
                    ),
                    const Expanded(
                      child: Text('I have read and agree to the Terms of Service and Privacy Policy.'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _hasAccepted ? _submit : null,
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
