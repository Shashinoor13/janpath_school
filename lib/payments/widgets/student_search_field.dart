import 'package:flutter/material.dart';
import 'package:janpath_school/config/database.dart';
import 'package:janpath_school/models/class_fee.dart';
import 'package:janpath_school/models/student.dart';
import 'package:janpath_school/models/student_bill.dart';

class StudentSearchField extends StatefulWidget {
  final void Function(Student, String, String, List<UnpaidBillInfo>) onSelected;
  const StudentSearchField({super.key, required this.onSelected});

  @override
  State<StudentSearchField> createState() => _StudentSearchFieldState();
}

class _StudentSearchFieldState extends State<StudentSearchField> {
  final TextEditingController _controller = TextEditingController();
  final DatabaseHelper _db = DatabaseHelper();

  List<_StudentSuggestion> _suggestions = [];
  bool _isLoading = false;

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final students = await _db.getStudentByName(query);

      List<_StudentSuggestion> result = [];
      if (students != null) {
        for (var student in students) {
          if (student != null) {
            final unpaidBills = await _getUnpaidBills(student);
            final className = await _getClassName(student.classId);
            final sectionName = await _getSectionName(student.sectionId);

            result.add(
              _StudentSuggestion(
                student: student,
                className: className,
                sectionName: sectionName,
                unpaidBills: unpaidBills,
              ),
            );
          }
        }
      }

      setState(() {
        _isLoading = false;
        _suggestions = result;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _suggestions = [];
      });
      print('Search error: $e');
    }
  }

  Future<List<UnpaidBillInfo>> _getUnpaidBills(Student student) async {
    try {
      final bills = await _db.getStudentBills(studentId: student.id);
      List<UnpaidBillInfo> unpaid = [];

      for (var bill in bills) {
        final classFee = await _db.getClassFee(
          classId: student.classId,
          sectionId: student.sectionId,
          session: bill.session,
        );
        if (classFee == null) continue;

        final unpaidAmount = classFee.classFee - bill.amountPaid;
        if (unpaidAmount > 0) {
          unpaid.add(
            UnpaidBillInfo(
              bill: bill,
              classFee: classFee,
              unpaidAmount: unpaidAmount,
            ),
          );
        }
      }
      return unpaid;
    } catch (e) {
      print('Error getting unpaid bills: $e');
      return [];
    }
  }

  Future<String> _getClassName(int? classId) async {
    if (classId == null) return 'Unknown';
    try {
      final schoolClass = await _db.getClass(id: classId);
      return schoolClass?.name ?? 'Unknown';
    } catch (e) {
      print('Error getting class name: $e');
      return 'Unknown';
    }
  }

  Future<String> _getSectionName(int? sectionId) async {
    if (sectionId == null) return '';
    try {
      final section = await _db.getSection(sectionId: sectionId);
      return section?.name ?? '';
    } catch (e) {
      print('Error getting section name: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: "नाम टाइप गर्नुहोस्...",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          onChanged: _search,
        ),

        if (_isLoading)
          Container(
            margin: const EdgeInsets.only(top: 4),
            child: const LinearProgressIndicator(),
          ),

        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final s = _suggestions[index];
                final roll = s.student.rollNumber ?? "-";
                return ListTile(
                  title: Text(s.student.name ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Class: ${s.className}${s.sectionName.isNotEmpty ? '-${s.sectionName}' : ''}",
                      ),
                      Text("Roll: $roll"),
                      if (s.unpaidBills.isNotEmpty)
                        Text(
                          "${s.unpaidBills.length} unpaid bill(s)",
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    widget.onSelected(
                      s.student,
                      s.className,
                      s.sectionName,
                      s.unpaidBills,
                    );
                    _controller.text = s.student.name ?? '';
                    setState(() => _suggestions = []);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

class _StudentSuggestion {
  final Student student;
  final String className;
  final String sectionName;
  final List<UnpaidBillInfo> unpaidBills;

  _StudentSuggestion({
    required this.student,
    required this.className,
    required this.sectionName,
    required this.unpaidBills,
  });
}

class UnpaidBillInfo {
  final StudentBill bill;
  final ClassFee classFee;
  final double unpaidAmount;

  UnpaidBillInfo({
    required this.bill,
    required this.classFee,
    required this.unpaidAmount,
  });
}
