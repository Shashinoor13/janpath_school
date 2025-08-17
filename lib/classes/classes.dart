import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:janpath_school/app.dart';
import 'package:janpath_school/config/database.dart';
import 'package:janpath_school/db.dart';
import 'package:janpath_school/models/school_class.dart';
import 'package:janpath_school/models/section.dart';

extension DatabaseServiceExtensions on DatabaseService {
  static Future<List<Section>> getAllSections() async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('Section', orderBy: 'name ASC');
    return List.generate(maps.length, (i) => Section.fromMap(maps[i]));
  }

  static Future<int> createSection(Section section) async {
    final db = await DatabaseHelper().database;
    return await db.insert('Section', section.toMap());
  }

  static Future<int> deleteClass(int id) async {
    final db = await DatabaseHelper().database;
    await db.delete('Section', where: 'classId = ?', whereArgs: [id]);
    return await db.delete('Class', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteSection(int id) async {
    final db = await DatabaseHelper().database;
    return await db.delete('Section', where: 'id = ?', whereArgs: [id]);
  }
}

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  List<SchoolClass> classes = [];
  List<Section> sections = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final loadedClasses = await DatabaseService.getAllClasses();
      final loadedSections = await DatabaseServiceExtensions.getAllSections();
      setState(() {
        classes = loadedClasses;
        sections = loadedSections;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('डेटा लोड गर्न असफल: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BaseLayout(
      title: "Class Management",
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => context.go("/"),
            child: Text("Back to Dashboard"),
          ),

          Row(
            children: [
              _InfoCard(title: 'कुल कक्षा', count: classes.length),
              const SizedBox(width: 16),
              _InfoCard(title: 'कुल सेक्शन', count: sections.length),
              const Spacer(),
              ElevatedButton(
                onPressed: _showAddClassDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: Colors.black12,
                ),
                child: const Text(
                  'कक्षा थप्नुहोस्',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: classes.isEmpty
                ? const _EmptyWidget()
                : ListView.builder(
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final schoolClass = classes[index];
                      final classSections = sections
                          .where((section) => section.classId == schoolClass.id)
                          .toList();
                      return _ClassCard(
                        schoolClass: schoolClass,
                        sections: classSections,
                        onAddSection: () => _showAddSectionDialog(schoolClass),
                        onDeleteClass: () => _deleteClass(schoolClass),
                        onDeleteSection: _deleteSection,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddClassDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddClassDialog(
        onClassAdded: (name) async {
          final newClass = SchoolClass(name: name);
          await DatabaseService.createClass(newClass);
          _loadData();
        },
      ),
    );
  }

  void _showAddSectionDialog(SchoolClass schoolClass) {
    showDialog(
      context: context,
      builder: (context) => _AddSectionDialog(
        className: schoolClass.name,
        onSectionAdded: (name) async {
          final newSection = Section(name: name, classId: schoolClass.id!);
          await DatabaseServiceExtensions.createSection(newSection);
          _loadData();
        },
      ),
    );
  }

  Future<void> _deleteClass(SchoolClass schoolClass) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('कक्षा हटाउने'),
        content: Text('${schoolClass.name} कक्षा हटाउन निश्चित हुनुहुन्छ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('रद्द गर्नुहोस्'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('हटाउनुहोस्'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseServiceExtensions.deleteClass(schoolClass.id!);
      _loadData();
    }
  }

  Future<void> _deleteSection(Section section) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('सेक्शन हटाउने'),
        content: Text('${section.name} हटाउन निश्चित हुनुहुन्छ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('रद्द गर्नुहोस्'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('हटाउनुहोस्'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseServiceExtensions.deleteSection(section.id!);
      _loadData();
    }
  }
}
// ---------- Widgets ----------

class _InfoCard extends StatelessWidget {
  final String title;
  final int count;
  const _InfoCard({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.class_, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('कुनै कक्षा भेटिएन', style: theme.textTheme.titleMedium),
          Text('कक्षा थपेर सुरु गर्नुहोस्', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final SchoolClass schoolClass;
  final List<Section> sections;
  final VoidCallback onAddSection;
  final VoidCallback onDeleteClass;
  final Function(Section) onDeleteSection;

  const _ClassCard({
    required this.schoolClass,
    required this.sections,
    required this.onAddSection,
    required this.onDeleteClass,
    required this.onDeleteSection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'कक्षा ${schoolClass.name}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onAddSection,
                child: const Text('सेक्शन थप्नुहोस्'),
              ),
              TextButton(
                onPressed: onDeleteClass,
                child: const Text('हटाउनुहोस्'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          sections.isEmpty
              ? const Text('कुनै सेक्शन छैन')
              : Wrap(
                  spacing: 8,
                  children: sections
                      .map(
                        (s) => Chip(
                          label: Text(s.name),
                          onDeleted: () => onDeleteSection(s),
                          deleteIcon: const Icon(Icons.close, size: 16),
                        ),
                      )
                      .toList(),
                ),
        ],
      ),
    );
  }
}

class _AddClassDialog extends StatefulWidget {
  final Function(String) onClassAdded;
  const _AddClassDialog({required this.onClassAdded});
  @override
  State<_AddClassDialog> createState() => _AddClassDialogState();
}

class _AddClassDialogState extends State<_AddClassDialog> {
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('नयाँ कक्षा थप्नुहोस्'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: 'जस्तै: १०, ११, १२'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('रद्द गर्नुहोस्'),
        ),
        TextButton(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              widget.onClassAdded(_controller.text.trim());
              Navigator.pop(context);
            }
          },
          child: const Text('थप्नुहोस्'),
        ),
      ],
    );
  }
}

class _AddSectionDialog extends StatefulWidget {
  final String className;
  final Function(String) onSectionAdded;
  const _AddSectionDialog({
    required this.className,
    required this.onSectionAdded,
  });
  @override
  State<_AddSectionDialog> createState() => _AddSectionDialogState();
}

class _AddSectionDialogState extends State<_AddSectionDialog> {
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.className} कक्षामा सेक्शन थप्नुहोस्'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: 'जस्तै: A, B, C'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('रद्द गर्नुहोस्'),
        ),
        TextButton(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              widget.onSectionAdded(_controller.text.trim());
              Navigator.pop(context);
            }
          },
          child: const Text('थप्नुहोस्'),
        ),
      ],
    );
  }
}
