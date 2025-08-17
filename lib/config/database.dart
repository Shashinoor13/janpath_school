import 'package:janpath_school/models/class_fee.dart';
import 'package:janpath_school/models/note.dart';
import 'package:janpath_school/models/school_class.dart';
import 'package:janpath_school/models/section.dart';
import 'package:janpath_school/models/student.dart';
import 'package:janpath_school/models/student_bill.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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

    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    // Create Student table
    await db.execute('''
      CREATE TABLE Student (
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
      CREATE TABLE Class (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Create Section table
    await db.execute('''
      CREATE TABLE Section (
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
      CREATE TABLE ClassFee (
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
      CREATE TABLE StudentBill (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        billNumber TEXT,
        studentId INTEGER NOT NULL,
        classFeeId INTEGER NOT NULL,
        billedAt TEXT NOT NULL,
        amountPaid REAL NOT NULL,
        session TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (studentId) REFERENCES Student (id),
        FOREIGN KEY (classFeeId) REFERENCES ClassFee (id)
      )
    ''');

    // Create ExtraBill table
    await db.execute('''
      CREATE TABLE ExtraBill (
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
      CREATE TABLE Payment (
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
      CREATE TABLE PaymentItem (
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
      CREATE TABLE Note (
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

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
