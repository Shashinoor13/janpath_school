import 'package:go_router/go_router.dart';
import 'package:janpath_school/classes/classes.dart';
import 'package:janpath_school/dashboard/screens/dashboard.dart';
import 'package:janpath_school/payments/new_payment.dart';
import 'package:janpath_school/payments/payments.dart';
import 'package:janpath_school/settings/class.dart';
import 'package:janpath_school/settings/fee.dart';
import 'package:janpath_school/settings/settings.dart';
import 'package:janpath_school/student/new_student.dart';
import 'package:janpath_school/student/student.dart';
import 'package:janpath_school/student/student_detail.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'dashboard',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: DashboardScreen()),
    ),
    GoRoute(
      path: '/classes',
      name: 'classes',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: ClassesScreen()),
    ),
    GoRoute(
      path: '/payments',
      name: 'payments',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: PaymentsScreen()),
      routes: [
        GoRoute(
          path: 'new', // note: no leading slash inside nested route
          name: 'new-payment',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: NewPaymentScreen()),
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: SettingsScreen()),
      routes: [
        GoRoute(
          path: 'class',
          name: 'class-settings',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ClassSettingsScreen()),
        ),
        GoRoute(
          path: 'fee',
          name: 'fee-settings',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: FeeSettingsScreen()),
        ),
      ],
    ),
    GoRoute(
      path: '/students',
      name: 'students',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: StudentsScreen()),
      routes: [
        GoRoute(
          path: 'new',
          name: 'new-student',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: NewStudentScreen()),
        ),
        GoRoute(
          path: ':id',
          name: 'student-detail',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return NoTransitionPage(child: StudentDetailScreen(studentId: id));
          },
        ),
      ],
    ),
  ],
);
