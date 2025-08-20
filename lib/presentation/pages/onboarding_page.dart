import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_router.dart';
import '../../core/services/storage_service.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Handy',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Your DIY business platform',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                // Mark onboarding as seen
                await StorageService.setSetting('has_seen_onboarding', true);
                
                // Navigate to login
                if (context.mounted) {
                  context.go(AppRouter.login);
                }
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
