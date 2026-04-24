import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../controllers/visit_draft_controller.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/widgets/offline_map_widget.dart';
import '../../../core/storage/storage_provider.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../profile/profile_provider.dart';

class CreateVisitScreen extends StatelessWidget {
  const CreateVisitScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: Builder(builder: (context) => const _CreateVisitScreenInner()),
    );
  }
}

class _CreateVisitScreenInner extends ConsumerStatefulWidget {
  const _CreateVisitScreenInner();

  @override
  ConsumerState<_CreateVisitScreenInner> createState() => _CreateVisitScreenState();
}

class _CreateVisitScreenState extends ConsumerState<_CreateVisitScreenInner> {
  int _currentStep = 0;
  late final String _clientUuid;
  
  final GlobalKey _step1Key = GlobalKey();
  final GlobalKey _step2Key = GlobalKey();
  final GlobalKey _step3Key = GlobalKey();
  final GlobalKey _step4Key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _clientUuid = const Uuid().v4();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndStartTutorial();
    });
  }

  void _checkAndStartTutorial() async {
    final profileState = ref.read(profileStateProvider);
    final profile = profileState.value;
    
    final forceTutorial = profile?['force_tutorial'] == true;
    final tutorialCompleted = profile?['tutorial_completed'] == true;
    
    if (forceTutorial || !tutorialCompleted) {
      ShowCaseWidget.of(context).startShowCase([_step1Key, _step2Key, _step3Key, _step4Key]);
      if (!tutorialCompleted) {
        ref.read(profileStateProvider.notifier).completeTutorial();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // We would watch the draft here
    // final draft = ref.watch(visitDraftControllerProvider(_clientUuid));

    final storageUsage = ref.watch(deviceStorageProvider);
    final isCritical = storageUsage > 0.95;
    final isWarning = storageUsage > 0.80 && !isCritical;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Visit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: () => context.push('/settings/help'),
          ),
        ],
      ),
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
            title: Showcase(
              key: _step1Key,
              description: 'Start by filling out the basic details like date and country.',
              child: const Text('Basics'),
            ),
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
            title: Showcase(
              key: _step2Key,
              description: 'Next, select the core area and specific activity for this visit.',
              child: const Text('Activity'),
            ),
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
            title: Showcase(
              key: _step3Key,
              description: 'Add the different tree species planted and their counts here.',
              child: const Text('Trees'),
            ),
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
            title: Showcase(
              key: _step4Key,
              description: 'Finally, capture a group photo, collect a signature, and confirm your GPS location.',
              child: const Text('Evidence & Review'),
            ),
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
