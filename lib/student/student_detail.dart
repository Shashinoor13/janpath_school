import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:janpath_school/app.dart';

class StudentDetailScreen extends StatelessWidget {
  final String studentId;

  const StudentDetailScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'Student Detail',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              'Student ID: $studentId',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/students'),
              child: const Text('Back to Students'),
            ),
          ],
        ),
      ),
    );
  }
}
