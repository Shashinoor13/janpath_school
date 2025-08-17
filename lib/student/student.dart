import 'package:flutter/material.dart';
import 'package:janpath_school/app.dart';
import 'package:janpath_school/config/database.dart';
import 'package:janpath_school/models/school_class.dart';
import 'package:janpath_school/models/section.dart';
import 'package:janpath_school/models/student.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student> students = [];
  bool isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<String?> _getClassName(int? classId) async {
    if (classId == null) return 'Unknown';
    SchoolClass? schoolClass = await _databaseHelper.getClass(id: classId);
    return schoolClass?.name;
  }

  Future<String?> _getSectionName(int? sectionId) async {
    if (sectionId == null) return 'Unknown';
    Section? section = await _databaseHelper.getSection(sectionId: sectionId);
    return section?.name;
  }

  Future<void> _loadStudents({String? query}) async {
    setState(() => isLoading = true);
    final db = DatabaseHelper();
    // TODO: implement search using query
    final loadedStudents = await db.getStudents();
    setState(() {
      students = loadedStudents;
      isLoading = false;
    });
  }

  Future<double> _calculateDueAmount(
    int studentId,
    int classId,
    int sectionId,
  ) async {
    final db = DatabaseHelper();
    final bills = await db.getStudentBills(studentId: studentId);
    double totalPaid = bills.fold(0.0, (sum, bill) => sum + bill.amountPaid);

    double totalFee = 0.0;

    // For each bill, fetch the class fee and sum it up
    for (var bill in bills) {
      final classFee = await db.getClassFee(
        classId: classId,
        sectionId: sectionId,
        session: bill.session,
      );
      if (classFee != null) {
        totalFee += classFee.classFee;
      }
    }

    return totalFee - totalPaid;
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: "Student List",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText:
                    'नाम, इमेल, रोल नम्बर, कक्षा वा अभिभावकको नामले खोज्नुहोस्...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                // TODO: implement search call to database
                _loadStudents(query: value);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('नाम')),
                          DataColumn(label: Text('इमेल')),
                          DataColumn(label: Text('कक्षा')),
                          DataColumn(label: Text('सेक्शन')),
                          DataColumn(label: Text('रोल नम्बर')),
                          DataColumn(label: Text('अभिभावक')),
                          DataColumn(label: Text('माध्यम')),
                          DataColumn(label: Text('फोन')),
                          DataColumn(label: Text('बिल स्थिति')),
                          DataColumn(label: Text('बाँकी रकम')),
                          DataColumn(label: Text('कार्यहरू')),
                        ],
                        rows: students.map((s) {
                          return DataRow(
                            cells: [
                              DataCell(Text(s.id.toString())),
                              DataCell(Text(s.name)),
                              DataCell(Text(s.email ?? '-')),
                              DataCell(
                                FutureBuilder<String>(
                                  future: _getClassName(
                                    s.classId,
                                  ).then((value) => value ?? 'Unknown'),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Text('...');
                                    }
                                    return Text(snapshot.data!);
                                  },
                                ),
                              ),
                              DataCell(
                                FutureBuilder<String>(
                                  future: _getSectionName(
                                    s.sectionId,
                                  ).then((value) => value ?? 'Unknown'),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Text('...');
                                    }
                                    return Text(snapshot.data!);
                                  },
                                ),
                              ),
                              DataCell(Text(s.rollNumber ?? '-')),
                              DataCell(Text(s.guardianName ?? '-')),
                              DataCell(Text(s.medium ?? '-')),
                              DataCell(Text(s.phone ?? '-')),
                              DataCell(
                                FutureBuilder<double>(
                                  future: _calculateDueAmount(
                                    s.id!,
                                    s.classId!,
                                    s.sectionId!,
                                  ),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData)
                                      return const Text('Loading...');
                                    return Text(
                                      snapshot.data! <= 0
                                          ? 'भुक्तानी भयो'
                                          : 'बाँकी',
                                      style: TextStyle(
                                        color: snapshot.data! <= 0
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              DataCell(
                                FutureBuilder<double>(
                                  future: _calculateDueAmount(
                                    s.id!,
                                    s.classId!,
                                    s.sectionId!,
                                  ),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData)
                                      return const Text('-');
                                    return Text(
                                      '\$ Rs. ${snapshot.data!.toStringAsFixed(2)}',
                                    );
                                  },
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        // TODO: edit student
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.print),
                                      onPressed: () {
                                        // TODO: print student details
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
