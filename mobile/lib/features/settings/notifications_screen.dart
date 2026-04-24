import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = true;
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _whatsappEnabled = false;
  TimeOfDay? _quietStart;
  TimeOfDay? _quietEnd;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final data = await _supabase
          .from('notification_preferences')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (data != null) {
        setState(() {
          _pushEnabled = data['push_enabled'] ?? true;
          _emailEnabled = data['email_enabled'] ?? true;
          _whatsappEnabled = data['whatsapp_enabled'] ?? false;
          
          if (data['quiet_hours_start'] != null) {
            final parts = (data['quiet_hours_start'] as String).split(':');
            _quietStart = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          }
          if (data['quiet_hours_end'] != null) {
            final parts = (data['quiet_hours_end'] as String).split(':');
            _quietEnd = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load preferences: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _savePreferences() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      String? formatTime(TimeOfDay? time) {
        if (time == null) return null;
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
      }

      await _supabase.from('notification_preferences').upsert({
        'user_id': user.id,
        'push_enabled': _pushEnabled,
        'email_enabled': _emailEnabled,
        'whatsapp_enabled': _whatsappEnabled,
        'quiet_hours_start': formatTime(_quietStart),
        'quiet_hours_end': formatTime(_quietEnd),
        'timezone': DateTime.now().timeZoneName,
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferences saved successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save preferences: $e')));
      }
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? (_quietStart ?? TimeOfDay.now()) : (_quietEnd ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _quietStart = picked;
        } else {
          _quietEnd = picked;
        }
      });
      _savePreferences();
    }
  }

  Future<void> _testNotification() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      await _supabase.from('notification_events').insert({
        'event_type': 'visit.assigned',
        'payload': {'message': 'This is a test notification'},
        'recipient_user_id': user.id,
        'channels': ['push'],
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Test notification enqueued')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to enqueue test notification: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Delivery Channels',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive alerts on your device'),
            value: _pushEnabled,
            onChanged: (val) {
              setState(() => _pushEnabled = val);
              _savePreferences();
            },
          ),
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive updates via email'),
            value: _emailEnabled,
            onChanged: (val) {
              setState(() => _emailEnabled = val);
              _savePreferences();
            },
          ),
          SwitchListTile(
            title: const Text('WhatsApp Notifications'),
            subtitle: const Text('Receive critical alerts via WhatsApp'),
            value: _whatsappEnabled,
            onChanged: (val) {
              setState(() => _whatsappEnabled = val);
              _savePreferences();
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Quiet Hours',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text('Start Time'),
            trailing: Text(_quietStart?.format(context) ?? 'Not set'),
            onTap: () => _pickTime(true),
          ),
          ListTile(
            title: const Text('End Time'),
            trailing: Text(_quietEnd?.format(context) ?? 'Not set'),
            onTap: () => _pickTime(false),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _testNotification,
              icon: const Icon(Icons.notifications_active),
              label: const Text('Test Push Notification'),
            ),
          )
        ],
      ),
    );
  }
}
