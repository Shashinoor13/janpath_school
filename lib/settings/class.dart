import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:janpath_school/app.dart';

class ClassSettingsScreen extends StatefulWidget {
  const ClassSettingsScreen({super.key});

  @override
  State<ClassSettingsScreen> createState() => _ClassSettingsScreenState();
}

class _ClassSettingsScreenState extends State<ClassSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'Class Settings',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.class_, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text('Class Settings', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () => context.go('/settings'),
              child: const Text('Back to Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
