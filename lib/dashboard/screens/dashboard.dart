import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:janpath_school/app.dart';
import 'package:janpath_school/dashboard/widgets/action_button_grid.dart';
import 'package:janpath_school/dashboard/widgets/app_header.dart';
import 'package:janpath_school/dashboard/widgets/notes_section.dart';
import 'package:janpath_school/dashboard/widgets/welcome_section.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'Dashboard',
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WelcomeSection(),
                  const SizedBox(height: 32),
                  ActionButtonsGrid(
                    onAddStudent: () => context.go('/students/new'),
                    onMakePayment: () => context.go('/payments/new'),
                    onViewStudents: () => context.go('/students'),
                    onViewTransactions: () => context.go('/payments'),
                    onReports: () => context.go('/reports'),
                    onClasses: () => context.go('/classes'),
                    onFeeStructure: () => context.go('/settings/fee'),
                  ),
                  const SizedBox(height: 32),
                  const NotesSection(),
                ],
              ),
            ),
            const SizedBox(width: 32),
            const Expanded(flex: 1, child: QuickStatsSection()),
          ],
        ),
      ),
    );
  }
}
