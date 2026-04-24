import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../controllers/visit_draft_controller.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/widgets/offline_map_widget.dart';
import '../../../core/storage/storage_provider.dart';
class CreateVisitScreen extends ConsumerStatefulWidget {
  const CreateVisitScreen({super.key});

  @override
  ConsumerState<CreateVisitScreen> createState() => _CreateVisitScreenState();
}

class _CreateVisitScreenState extends ConsumerState<CreateVisitScreen> {
  int _currentStep = 0;
  late final String _clientUuid;

  @override
  void initState() {
    super.initState();
    _clientUuid = const Uuid().v4();
  }

  @override
  Widget build(BuildContext context) {
    // We would watch the draft here
    // final draft = ref.watch(visitDraftControllerProvider(_clientUuid));

    final storageUsage = ref.watch(deviceStorageProvider);
    final isCritical = storageUsage > 0.95;
    final isWarning = storageUsage > 0.80 && !isCritical;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Visit')),
      body: Column(
        children: [
          if (isCritical)
            Container(
              color: Colors.red,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: const Text('Device storage critically full (95%+). Cannot capture new visits until space is freed.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          if (isWarning)
            Container(
              color: Colors.orange,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: const Text('Storage running low (80%+). Please sync and clear local data soon.'),
            ),
          Expanded(
            child: IgnorePointer(
              ignoring: isCritical,
              child: Opacity(
                opacity: isCritical ? 0.5 : 1.0,
                child: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() => _currentStep += 1);
          } else {
            // ref.read(visitDraftControllerProvider(_clientUuid).notifier).submit();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        steps: [
          Step(
            title: const Text('Basics'),
            content: Column(
              children: [
                TextFormField(decoration: const InputDecoration(labelText: 'Scheduled Date & Time')),
                DropdownButtonFormField(items: const [], onChanged: (v) {}, decoration: const InputDecoration(labelText: 'Country')),
                // ... other fields
              ],
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Activity'),
            content: Column(
              children: [
                DropdownButtonFormField(items: const [], onChanged: (v) {}, decoration: const InputDecoration(labelText: 'Core Area')),
                DropdownButtonFormField(items: const [], onChanged: (v) {}, decoration: const InputDecoration(labelText: 'Activity')),
                // ... other fields
              ],
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Trees'),
            content: Column(
              children: [
                const Text('Dynamic list of species rows'),
                ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Add Species')),
                // ... trees list
              ],
            ),
            isActive: _currentStep >= 2,
          ),
          Step(
            title: const Text('Evidence & Review'),
            content: Column(
              children: [
                ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.camera_alt), label: const Text('Group Photo (Required)')),
                ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.draw), label: const Text('Signature')),
                const SizedBox(height: 16),
                const Text('Set Location (Offline Maps Supported)'),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const OfflineMapWidget(
                      initialCenter: LatLng(-6.173, 35.741),
                      initialZoom: 10.0,
                      interactive: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(decoration: const InputDecoration(labelText: 'Comments'), maxLines: 3),
              ],
            ),
            isActive: _currentStep >= 3,
          ),
        ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
