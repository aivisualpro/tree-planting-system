import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../controllers/visit_draft_controller.dart';
// other imports

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

    return Scaffold(
      appBar: AppBar(title: const Text('Create Visit')),
      body: Stepper(
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
                ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.location_on), label: const Text('Capture GPS')),
                TextFormField(decoration: const InputDecoration(labelText: 'Comments'), maxLines: 3),
              ],
            ),
            isActive: _currentStep >= 3,
          ),
        ],
      ),
    );
  }
}
