import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:janpath_school/app.dart';
import 'package:janpath_school/config/database.dart';
import 'package:janpath_school/models/class_fee.dart';
import 'package:janpath_school/models/school_class.dart';
import 'package:janpath_school/models/section.dart';

class FeeSettingsScreen extends StatefulWidget {
  const FeeSettingsScreen({super.key});

  @override
  State<FeeSettingsScreen> createState() => _FeeSettingsScreenState();
}

class _FeeSettingsScreenState extends State<FeeSettingsScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final _feeAmountController = TextEditingController();
  final _sessionController = TextEditingController();

  List<SchoolClass> _classes = [];
  List<Section> _sections = []; // Current sections for selected class
  List<ClassFee> _classFees = [];

  SchoolClass? _selectedClass;
  Section? _selectedSection;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _feeAmountController.dispose();
    _sessionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final classes = await _databaseHelper.getClasses();
      final classFees = await _databaseHelper.getClassFees();

      print(classFees);

      setState(() {
        _classes = classes;
        _classFees = classFees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error loading data: $e');
    }
  }

  Future<void> _loadSections(int classId) async {
    try {
      final sections = await _databaseHelper.getSections(classId: classId);
      setState(() {
        _sections = sections;
        _selectedSection = null;
      });
    } catch (e) {
      _showErrorSnackBar('Error loading sections: $e');
    }
  }

  Future<void> _addFee() async {
    if (_selectedClass == null ||
        _selectedSection == null ||
        _feeAmountController.text.isEmpty ||
        _sessionController.text.isEmpty) {
      _showErrorSnackBar('Please fill all fields');
      return;
    }

    final feeAmount = double.tryParse(_feeAmountController.text);
    if (feeAmount == null || feeAmount <= 0) {
      _showErrorSnackBar('Please enter a valid fee amount');
      return;
    }

    try {
      final now = DateTime.now();
      final classFee = ClassFee(
        classId: _selectedClass!.id,
        sectionId: _selectedSection!.id,
        classFee: feeAmount,
        session: _sessionController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );

      print(classFee);

      await _databaseHelper.insertClassFee(classFee);

      // Clear form
      _feeAmountController.clear();
      _sessionController.clear();
      setState(() {
        _selectedClass = null;
        _selectedSection = null;
        _sections = [];
      });

      // Reload data
      await _loadData();

      _showSuccessSnackBar('Fee added successfully');
    } catch (e) {
      _showErrorSnackBar('Error adding fee: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  String _getClassName(int? classId) {
    if (classId == null) return 'Unknown';
    final schoolClass = _classes.firstWhere(
      (c) => c.id == classId,
      orElse: () => SchoolClass(
        id: 0,
        name: 'Unknown',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return schoolClass.name;
  }

  Future<String> _getSectionName(int? sectionId) async {
    if (sectionId == null) return 'Unknown';
    Section? section = await _databaseHelper.getSection(sectionId: sectionId);
    if (section == null) return 'Unknown';
    return section.name;
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'Class Fees',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Class Dropdown
                              Expanded(
                                child: DropdownButtonFormField<SchoolClass>(
                                  value: _selectedClass,
                                  decoration: const InputDecoration(
                                    labelText: 'Select Class',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _classes.map((schoolClass) {
                                    return DropdownMenuItem<SchoolClass>(
                                      value: schoolClass,
                                      child: Text(schoolClass.name),
                                    );
                                  }).toList(),
                                  onChanged: (SchoolClass? value) {
                                    setState(() {
                                      _selectedClass = value;
                                      _selectedSection = null;
                                      _sections = [];
                                    });
                                    if (value != null) {
                                      _loadSections(value.id!);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Section Dropdown
                              Expanded(
                                child: DropdownButtonFormField<Section>(
                                  value: _selectedSection,
                                  decoration: const InputDecoration(
                                    labelText: 'Select Section',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _sections.map((section) {
                                    return DropdownMenuItem<Section>(
                                      value: section,
                                      child: Text(section.name),
                                    );
                                  }).toList(),
                                  onChanged: (Section? value) {
                                    setState(() {
                                      _selectedSection = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              // Fee Amount
                              Expanded(
                                child: TextField(
                                  controller: _feeAmountController,
                                  decoration: const InputDecoration(
                                    labelText: 'Fee Amount',
                                    border: OutlineInputBorder(),
                                    prefixText: 'Rs. ',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Session
                              Expanded(
                                child: TextField(
                                  controller: _sessionController,
                                  decoration: const InputDecoration(
                                    labelText: 'Session (e.g. 2025)',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton(
                              onPressed: _addFee,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Add Fee'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Table Section
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Fee Structure',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: _classFees.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No fees configured yet',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : SingleChildScrollView(
                                      child: DataTable(
                                        columns: const [
                                          DataColumn(label: Text('Class')),
                                          DataColumn(label: Text('Section')),
                                          DataColumn(label: Text('Fee Amount')),
                                          DataColumn(label: Text('Session')),
                                        ],
                                        rows: _classFees.map((classFee) {
                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                Text(
                                                  _getClassName(
                                                    classFee.classId,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                FutureBuilder<String>(
                                                  future: _getSectionName(
                                                    classFee.sectionId,
                                                  ),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) {
                                                      print("FOUND");
                                                      return Text(
                                                        snapshot.data!,
                                                      );
                                                    } else {
                                                      print(snapshot);
                                                      return const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  'Rs. ${classFee.classFee.toStringAsFixed(2)}',
                                                ),
                                              ),
                                              DataCell(Text(classFee.session)),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Back Button
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
