import 'package:janpath_school/models/class_fee.dart';
import 'package:janpath_school/models/note.dart';
import 'package:janpath_school/models/payment.dart';
import 'package:janpath_school/models/school_class.dart';
import 'package:janpath_school/models/section.dart';
import 'package:janpath_school/models/student.dart';
import 'package:janpath_school/models/student_bill.dart';
import 'package:janpath_school/payments/widgets/student_search_field.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class UnpaidBillInfo {
  final StudentBill bill;
  final double unpaidAmount;
  final ClassFee? classFee;

  UnpaidBillInfo({
    required this.bill,
    required this.unpaidAmount,
    this.classFee,
  });

  static UnpaidBillInfo fromMap(Map<String, dynamic> map) {
    return UnpaidBillInfo(
      bill: StudentBill.fromMap(map),
      unpaidAmount: map['unpaidAmount'],
      classFee: map['classFee'] != null
          ? ClassFee.fromMap(map['classFee'])
          : null,
    );
  }
}

class PaymentDistribution {
  final int billId;
  final double amountToPay;
  final double remainingDue;

  PaymentDistribution({
    required this.billId,
    required this.amountToPay,
    required this.remainingDue,
  });
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'school_management.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add any new columns or tables for version 2
      await _createTables(db, newVersion);
    }
  }

  Future<void> _createTables(Database db, int version) async {
    // Create Student table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Student (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        address TEXT,
        classId INTEGER,
        sectionId INTEGER,
        rollNumber TEXT,
        guardianName TEXT,
        medium TEXT,
        session TEXT,
        parentName TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (classId) REFERENCES Class (id),
        FOREIGN KEY (sectionId) REFERENCES Section (id)
      )
    ''');

    // Create Class table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Class (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Create Section table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Section (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        classId INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (classId) REFERENCES Class (id),
        UNIQUE(name, classId)
      )
    ''');

    // Create ClassFee table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ClassFee (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        classId INTEGER,
        sectionId INTEGER,
        classFee REAL NOT NULL,
        session TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (classId) REFERENCES Class (id),
        FOREIGN KEY (sectionId) REFERENCES Section (id),
        UNIQUE(classId, sectionId, session)
      )
    ''');

    // Create StudentBill table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS StudentBill (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        billNumber TEXT,
        studentId INTEGER NOT NULL,
        classFeeId INTEGER NOT NULL,
        billedAt TEXT NOT NULL,
        amountPaid REAL NOT NULL DEFAULT 0.0,
        session TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (studentId) REFERENCES Student (id),
        FOREIGN KEY (classFeeId) REFERENCES ClassFee (id)
      )
    ''');

    // Create ExtraBill table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ExtraBill (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        billNumber TEXT,
        studentId INTEGER NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        billedAt TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (studentId) REFERENCES Student (id)
      )
    ''');

    // Create Payment table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Payment (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        billNumber TEXT,
        date TEXT,
        studentName TEXT,
        class TEXT,
        rollNumber TEXT,
        guardianName TEXT,
        medium TEXT,
        session TEXT,
        parentName TEXT,
        address TEXT,
        totalAmount REAL,
        totalInWords TEXT,
        accountantSignature TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Create PaymentItem table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS PaymentItem (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paymentId INTEGER NOT NULL,
        sn INTEGER NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        remarks TEXT,
        FOREIGN KEY (paymentId) REFERENCES Payment (id)
      )
    ''');

    // Create Note table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Note (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  // CRUD operations for Student
  Future<int> insertStudent(Student student) async {
    final db = await database;
    return await db.insert('Student', student.toMap());
  }

  Future<List<Student>> getStudents() async {
    final db = await database;
    final maps = await db.query('Student', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  Future<Student?> getStudent(int id) async {
    final db = await database;
    final maps = await db.query('Student', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Student.fromMap(maps.first);
  }

  Future<List<Student?>?> getStudentByName(String name) async {
    final db = await database;
    final maps = await db.query(
      'Student',
      where: 'name LIKE ?',
      whereArgs: ['%${name.trim()}%'],
      distinct: true,
    );
    if (maps.isEmpty) return null;
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  Future<int> updateStudent(Student student) async {
    final db = await database;
    return await db.update(
      'Student',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final db = await database;
    return await db.delete('Student', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD operations for Class
  Future<int> insertClass(SchoolClass schoolClass) async {
    final db = await database;
    return await db.insert('Class', schoolClass.toMap());
  }

  Future<List<SchoolClass>> getClasses() async {
    final db = await database;
    final maps = await db.query('Class', orderBy: 'name ASC');
    return List.generate(maps.length, (i) => SchoolClass.fromMap(maps[i]));
  }

  Future<SchoolClass?> getClass({int? id}) async {
    final db = await database;
    final maps = await db.query('Class', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return SchoolClass.fromMap(maps.first);
  }

  // CRUD operations for Section
  Future<int> insertSection(Section section) async {
    final db = await database;
    return await db.insert('Section', section.toMap());
  }

  Future<List<Section>> getSections({int? classId}) async {
    final db = await database;
    final maps = classId != null
        ? await db.query('Section', where: 'classId = ?', whereArgs: [classId])
        : await db.query('Section');
    return List.generate(maps.length, (i) => Section.fromMap(maps[i]));
  }

  Future<Section?> getSection({int? sectionId}) async {
    final db = await database;
    final maps = await db.query(
      'Section',
      where: 'id = ?',
      whereArgs: [sectionId],
    );
    if (maps.isEmpty) return null;
    return Section.fromMap(maps.first);
  }

  // CRUD operations for ClassFee
  Future<int> insertClassFee(ClassFee classFee) async {
    final db = await database;
    return await db.insert('ClassFee', classFee.toMap());
  }

  Future<List<ClassFee>> getClassFees() async {
    final db = await database;
    final maps = await db.query('ClassFee');
    return List.generate(maps.length, (i) => ClassFee.fromMap(maps[i]));
  }

  Future<ClassFee?> getClassFee({
    int? classId,
    int? sectionId,
    String? session,
  }) async {
    final db = await database;
    List<Map<String, Object?>> maps = await db.query(
      'ClassFee',
      where: 'classId = ? AND sectionId = ? AND session = ?',
      whereArgs: [classId, sectionId, session],
    );
    if (maps.isEmpty) {
      maps = await db.query(
        'ClassFee',
        where: 'classId = ? AND sectionId = ?',
        whereArgs: [classId, sectionId],
        orderBy: 'id ASC',
        limit: 1,
      );
    }
    if (maps.isEmpty) return null;
    return ClassFee.fromMap(maps.first);
  }

  // CRUD operations for Note
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('Note', note.toMap());
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final maps = await db.query('Note', orderBy: 'updatedAt DESC');
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'Note',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // CRUD operations for StudentBill
  Future<int> insertStudentBill(StudentBill studentBill) async {
    final db = await database;
    return await db.insert('StudentBill', studentBill.toMap());
  }

  Future<List<StudentBill>> getStudentBills({int? studentId}) async {
    final db = await database;
    List<Map<String, Object?>> maps;
    if (studentId != null) {
      maps = await db.query(
        'StudentBill',
        where: 'studentId = ?',
        whereArgs: [studentId],
      );
    } else {
      maps = await db.query('StudentBill');
    }
    return List.generate(maps.length, (i) => StudentBill.fromMap(maps[i]));
  }

  Future<int> updateStudentBill(StudentBill studentBill) async {
    final db = await database;
    return await db.update(
      'StudentBill',
      studentBill.toMap(),
      where: 'id = ?',
      whereArgs: [studentBill.id],
    );
  }

  // Get unpaid bills for a student
  Future<List<UnpaidBillInfo>> getUnpaidBillsForStudent(int studentId) async {
    final db = await database;
    final query = '''
      SELECT sb.*, cf.classFee, cf.session as feeSession
      FROM StudentBill sb
      JOIN ClassFee cf ON sb.classFeeId = cf.id
      WHERE sb.studentId = ? AND sb.amountPaid < cf.classFee
      ORDER BY sb.billedAt ASC
    ''';

    final maps = await db.rawQuery(query, [studentId]);

    List<UnpaidBillInfo> unpaidBills = [];
    for (var map in maps) {
      final bill = StudentBill.fromMap(map);
      final classFeeAmount = map['classFee'] as double;
      final unpaidAmount = classFeeAmount - bill.amountPaid;

      if (unpaidAmount > 0) {
        unpaidBills.add(UnpaidBillInfo(bill: bill, unpaidAmount: unpaidAmount));
      }
    }

    return unpaidBills;
  }

  // Payment operations
  Future<Map<String, dynamic>> savePayment(
    Map<String, dynamic> paymentData,
  ) async {
    final db = await database;

    return await db.transaction<Map<String, dynamic>>((txn) async {
      // Create the payment record
      final payment = Payment(
        billNumber: paymentData['billNumber'],
        date: paymentData['date'] != null
            ? DateTime.parse(paymentData['date'])
            : null,
        studentName: paymentData['studentName'],
        classValue: paymentData['class'],
        rollNumber: paymentData['rollNumber'],
        guardianName: paymentData['guardianName'],
        medium: paymentData['paymentMode'],
        session: paymentData['session'],
        parentName: paymentData['parentName'],
        address: paymentData['address'],
        totalAmount: paymentData['totalAmount'],
        totalInWords: paymentData['totalInWords'],
        accountantSignature: paymentData['accountantSignature'],
        createdAt: DateTime.now(),
      );

      final paymentId = await txn.insert('Payment', payment.toMap());

      // Insert payment items
      if (paymentData['items'] != null) {
        for (int i = 0; i < paymentData['items'].length; i++) {
          final item = paymentData['items'][i];
          final paymentItem = PaymentItem(
            paymentId: paymentId,
            sn: i + 1,
            description: item['description'],
            amount: item['amount'],
            remarks: item['remarks'],
          );
          await txn.insert('PaymentItem', paymentItem.toMap());
        }
      }

      // Update student bills if billIds are provided
      List<Map<String, dynamic>> updatedBills = [];
      if (paymentData['billIds'] != null && paymentData['billIds'].isNotEmpty) {
        final billIds = List<int>.from(paymentData['billIds']);

        // Get student bills with class fees
        final billsQuery =
            '''
          SELECT sb.*, cf.classFee
          FROM StudentBill sb
          JOIN ClassFee cf ON sb.classFeeId = cf.id
          WHERE sb.id IN (${billIds.map((e) => '?').join(',')})
        ''';

        final billMaps = await txn.rawQuery(billsQuery, billIds);

        // Distribute payment across bills
        final paymentDistribution = _distributeBillPayment(
          billMaps,
          paymentData['totalAmount'],
        );

        // Update each bill
        for (final distribution in paymentDistribution) {
          if (distribution.amountToPay > 0) {
            await txn.rawUpdate(
              '''
              UPDATE StudentBill 
              SET amountPaid = amountPaid + ?, updatedAt = ?
              WHERE id = ?
            ''',
              [
                distribution.amountToPay,
                DateTime.now().toIso8601String(),
                distribution.billId,
              ],
            );

            updatedBills.add({
              'billId': distribution.billId,
              'paymentApplied': distribution.amountToPay,
              'remainingDue': distribution.remainingDue,
            });
          }
        }
      }

      return {
        'success': true,
        'paymentId': paymentId,
        'payment': payment.copyWith(id: paymentId),
        'updatedBills': updatedBills,
        'message': 'भुक्तानी सफलतापूर्वक बुझाइयो!',
      };
    });
  }

  // Payment distribution logic (similar to your Prisma function)
  List<PaymentDistribution> _distributeBillPayment(
    List<Map<String, dynamic>> bills,
    double totalPayment,
  ) {
    List<PaymentDistribution> distribution = [];
    double remainingPayment = totalPayment;

    // Sort bills by creation date (oldest first)
    bills.sort((a, b) {
      final dateA = DateTime.parse(a['billedAt']);
      final dateB = DateTime.parse(b['billedAt']);
      return dateA.compareTo(dateB);
    });

    for (final bill in bills) {
      if (remainingPayment <= 0) break;

      final classFee = bill['classFee'] as double;
      final amountPaid = bill['amountPaid'] as double;
      final dueAmount = classFee - amountPaid;

      if (dueAmount > 0) {
        final amountToPay = remainingPayment >= dueAmount
            ? dueAmount
            : remainingPayment;
        final remainingDue = dueAmount - amountToPay;

        distribution.add(
          PaymentDistribution(
            billId: bill['id'] as int,
            amountToPay: amountToPay,
            remainingDue: remainingDue,
          ),
        );

        remainingPayment -= amountToPay;
      }
    }

    return distribution;
  }

  // Get payment history
  Future<List<Payment>> getPayments({int? limit}) async {
    final db = await database;
    final maps = await db.query(
      'Payment',
      orderBy: 'createdAt DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => Payment.fromMap(maps[i]));
  }

  Future<Payment?> getPayment(int id) async {
    final db = await database;
    final maps = await db.query('Payment', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Payment.fromMap(maps.first);
  }

  Future<List<PaymentItem>> getPaymentItems(int paymentId) async {
    final db = await database;
    final maps = await db.query(
      'PaymentItem',
      where: 'paymentId = ?',
      whereArgs: [paymentId],
      orderBy: 'sn ASC',
    );
    return List.generate(maps.length, (i) => PaymentItem.fromMap(maps[i]));
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
