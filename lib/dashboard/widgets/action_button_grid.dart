import 'package:flutter/material.dart';

class ActionButtonsGrid extends StatelessWidget {
  final VoidCallback? onAddStudent;
  final VoidCallback? onMakePayment;
  final VoidCallback? onViewStudents;
  final VoidCallback? onViewTransactions;
  final VoidCallback? onReports;
  final VoidCallback? onClasses;
  final VoidCallback? onFeeStructure;

  const ActionButtonsGrid({
    super.key,
    this.onAddStudent,
    this.onMakePayment,
    this.onViewStudents,
    this.onViewTransactions,
    this.onReports,
    this.onClasses,
    this.onFeeStructure,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        ActionButton(
          icon: Icons.person_add,
          label: 'Add Student',
          color: Colors.indigo[500]!,
          onTap: onAddStudent ?? () {},
        ),
        ActionButton(
          icon: Icons.payment,
          label: 'Make Payment',
          color: Colors.green[500]!,
          onTap: onMakePayment ?? () {},
        ),
        ActionButton(
          icon: Icons.group,
          label: 'View Students',
          color: Colors.blue[500]!,
          onTap: onViewStudents ?? () {},
        ),
        ActionButton(
          icon: Icons.receipt_long,
          label: 'View Transactions',
          color: Colors.purple[500]!,
          onTap: onViewTransactions ?? () {},
        ),
        ActionButton(
          icon: Icons.bar_chart,
          label: 'Reports',
          color: Colors.orange[600]!,
          onTap: onReports ?? () {},
        ),
        ActionButton(
          icon: Icons.class_,
          label: 'Classes',
          color: Colors.amber[600]!,
          onTap: onClasses ?? () {},
        ),
        ActionButton(
          icon: Icons.settings,
          label: 'Fee Structure',
          color: Colors.pink[500]!,
          onTap: onFeeStructure ?? () {},
        ),
      ],
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 160,
        height: 80,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
