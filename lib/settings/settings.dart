import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:janpath_school/app.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'Settings',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.settings, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Settings', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/settings/class'),
              child: const Text('Class Settings'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.go('/settings/fee'),
              child: const Text('Fee Settings'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
