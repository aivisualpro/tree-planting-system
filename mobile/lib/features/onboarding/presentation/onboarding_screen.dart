import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onIntroEnd(BuildContext context) {
    context.go('/preload');
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Welcome to Tree-Planting",
          body: "Join us in our mission to reforest and empower communities.",
          image: const Center(
            child: Icon(Icons.park, size: 100, color: Colors.green),
          ),
          decoration: const PageDecoration(
            pageColor: Colors.white,
          ),
        ),
        PageViewModel(
          title: "Works offline — always",
          body: "No internet? No problem. The app works perfectly offline.",
          image: const Center(
            child: Icon(Icons.wifi_off, size: 100, color: Colors.blueGrey),
          ),
          decoration: const PageDecoration(
            pageColor: Colors.white,
          ),
        ),
        PageViewModel(
          title: "Capture photos + GPS + signatures",
          body: "Easily document your visits with photos, precise location, and farmer signatures.",
          image: const Center(
            child: Icon(Icons.camera_alt, size: 100, color: Colors.blue),
          ),
          decoration: const PageDecoration(
            pageColor: Colors.white,
          ),
        ),
        PageViewModel(
          title: "Sync happens automatically — just keep working",
          body: "As soon as you regain connectivity, your data syncs securely to the cloud.",
          image: const Center(
            child: Icon(Icons.cloud_sync, size: 100, color: Colors.orange),
          ),
          decoration: const PageDecoration(
            pageColor: Colors.white,
          ),
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: Theme.of(context).primaryColor,
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0)
        ),
      ),
    );
  }
}
