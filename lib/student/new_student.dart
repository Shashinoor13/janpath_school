import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:janpath_school/app.dart';
import 'package:janpath_school/config/database.dart';
import 'package:janpath_school/models/class_fee.dart';
import 'package:janpath_school/models/school_class.dart';
import 'package:janpath_school/models/section.dart';
import 'package:janpath_school/models/student.dart';
import 'package:janpath_school/models/student_bill.dart';

class NewStudentScreen extends StatefulWidget {
  const NewStudentScreen({super.key});

  @override
  State<NewStudentScreen> createState() => _NewStudentScreenState();
}

class _NewStudentScreenState extends State<NewStudentScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Individual controllers for each field
  final _studentNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _sessionController = TextEditingController();
  final _parentsNameController = TextEditingController();
  final _guardianNameController = TextEditingController();

  SchoolClass? _selectedClass;
  Section? _selectedSection;
  final List<String> _mediums = ["English", "Nepali"];

  List<SchoolClass> _classes = [];
  List<Section> _sections = [];
  String? _selectedMedium;
  bool _isLoading = true;

  @override
  void dispose() {
    _studentNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _rollNumberController.dispose();
    _sessionController.dispose();
    _parentsNameController.dispose();
    _guardianNameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final classes = await _databaseHelper.getClasses();

      setState(() {
        _classes = classes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSections(int classId) async {
    try {
      final sections = await _databaseHelper.getSections(classId: classId);
      setState(() {
        _sections = sections;
        _selectedSection = null;
      });
    } catch (e) {}
  }

  Future<void> _saveStudentDetails() async {
    if (_studentNameController.text.isEmpty) {
      return;
    }
    if (_selectedClass == null || _selectedSection == null) {
      return;
    }
    if (_sessionController.text.isEmpty) {
      return;
    }

    _selectedMedium ??= "Nepali";

    Student student = Student(
      name: _studentNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _locationController.text,
      classId: _selectedClass?.id,
      sectionId: _selectedSection?.id,
      rollNumber: _rollNumberController.text,
      guardianName: _guardianNameController.text,
      medium: _selectedMedium,
      session: _sessionController.text,
      parentName: _parentsNameController.text,
    );
    DatabaseHelper _databaseHelper = DatabaseHelper();
    int studentId = await _databaseHelper.insertStudent(student);
    print(_selectedClass?.id);

    ClassFee? classFee = await _databaseHelper.getClassFee(
      classId: _selectedClass?.id,
      sectionId: _selectedSection?.id,
      session: _sessionController.text.toString().toLowerCase(),
    );

    print(classFee);

    StudentBill studentBill = StudentBill(
      studentId: studentId,
      classFeeId: classFee!.id!,
      amountPaid: 0,
      session: _sessionController.text.toString(),
    );

    int billId = await _databaseHelper.insertStudentBill(studentBill);

    if (billId > 0 && studentId > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Student added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? hintText,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ] else ...[
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) getDisplayText,
    required void Function(T?) onChanged,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ] else ...[
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(getDisplayText(item)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const BaseLayout(
        title: 'New Student',
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return BaseLayout(
      title: '',
      child: Container(
        color: Colors.grey[50],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'नयाँ विद्यार्थी दर्ता',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'विद्यार्थीको जानकारी भर्नुहोस् र दर्ता पुरा गर्नुहोस्',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // Three Column Layout
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 1200) {
                    // Three columns for large screens
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column - Personal Information
                        Expanded(
                          child: _buildCard(
                            title: 'व्यक्तिगत जानकारी',
                            children: [
                              Text(
                                'विद्यार्थीको आधारभूत जानकारी',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildFormField(
                                label: 'पूरा नाम',
                                controller: _studentNameController,
                                hintText: 'विद्यार्थीको पूरा नाम',
                                icon: Icons.person,
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'आवश्यक',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildFormField(
                                label: 'इमेल ठेगाना',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                hintText: 'student@example.com',
                                icon: Icons.email,
                              ),
                              const SizedBox(height: 20),
                              _buildFormField(
                                label: 'फोन नम्बर',
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                hintText: '98XXXXXXXX',
                                icon: Icons.phone,
                              ),
                              const SizedBox(height: 20),
                              _buildFormField(
                                label: 'ठेगाना',
                                controller: _locationController,
                                hintText: 'पूरा ठेगाना लेख्नुहोस्',
                                icon: Icons.location_on,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Middle Column - Academic Information
                        Expanded(
                          child: _buildCard(
                            title: 'शैक्षिक जानकारी',
                            children: [
                              Text(
                                'कक्षा र अध्ययन सम्बन्धी विवरण',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildDropdownField<SchoolClass>(
                                label: 'कक्षा',
                                value: _selectedClass,
                                items: _classes,
                                getDisplayText: (item) => item.name,
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
                                icon: Icons.school,
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'आवश्यक',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildDropdownField<Section>(
                                label: 'सेक्सन',
                                value: _selectedSection,
                                items: _sections,
                                getDisplayText: (item) => item.name,
                                onChanged: (Section? value) {
                                  setState(() {
                                    _selectedSection = value;
                                  });
                                },
                                icon: Icons.group,
                              ),
                              const SizedBox(height: 20),
                              _buildFormField(
                                label: 'रोल नम्बर',
                                controller: _rollNumberController,
                                keyboardType: TextInputType.number,
                                hintText: 'जस्तै: 001, A01',
                              ),
                              const SizedBox(height: 20),
                              _buildDropdownField<String>(
                                label: 'अध्ययन माध्यम',
                                value: _selectedMedium,
                                items: _mediums,
                                getDisplayText: (item) => item,
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedMedium = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildFormField(
                                label: 'सत्र',
                                controller: _sessionController,
                                hintText: 'जस्तै: 2081-2082',
                                icon: Icons.calendar_today,
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'आवश्यक',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Right Column - Guardian Information
                        Expanded(
                          child: _buildCard(
                            title: 'अभिभावक जानकारी',
                            children: [
                              Text(
                                'अभिभावक र परिवारका विवरण',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildFormField(
                                label: 'अभिभावकको नाम',
                                controller: _parentsNameController,
                                hintText: 'अभिभावकको पूरा नाम',
                                icon: Icons.person,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'शिक्षा प्रेमी श्री/श्रीमती',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _guardianNameController,
                                decoration: InputDecoration(
                                  hintText: 'शिक्षा प्रेमी श्री/श्रीमतीको नाम',
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors.blue,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Fee Information
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'दर्ता स्थिति',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[800],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoRow('नाम:', 'बाँकी'),
                                    const SizedBox(height: 8),
                                    _buildInfoRow('कक्षा:', 'बाँकी'),
                                    const SizedBox(height: 8),
                                    _buildInfoRow('सेक्सन:', 'बैकल्पिक'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Single column for smaller screens
                    return Column(
                      children: [
                        _buildCard(
                          title: 'व्यक्तिगत जानकारी',
                          children: [
                            // All form fields in single column
                            _buildFormField(
                              label: 'पूरा नाम',
                              controller: _studentNameController,
                              hintText: 'विद्यार्थीको पूरा नाम',
                              icon: Icons.person,
                            ),
                            // ... rest of the fields
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => context.go('/students'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('रद्द गर्नुहोस्'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveStudentDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('विद्यार्थी दर्ता गर्नुहोस्'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
