import 'package:janpath_school/config/database.dart';
import 'package:janpath_school/models/note.dart';
import 'package:janpath_school/models/school_class.dart';
import 'package:janpath_school/models/student.dart';

class DatabaseService {
  static final DatabaseHelper _databaseHelper = DatabaseHelper();

  static Future<void> initializeDatabase() async {
    await _databaseHelper.database;
  }

  // Student operations
  static Future<int> createStudent(Student student) async {
    return await _databaseHelper.insertStudent(student);
  }

  static Future<List<Student>> getAllStudents() async {
    return await _databaseHelper.getStudents();
  }

  static Future<Student?> getStudentById(int id) async {
    return await _databaseHelper.getStudent(id);
  }

  // Class operations
  static Future<int> createClass(SchoolClass schoolClass) async {
    return await _databaseHelper.insertClass(schoolClass);
  }

  static Future<List<SchoolClass>> getAllClasses() async {
    return await _databaseHelper.getClasses();
  }

  // Note operations
  static Future<int> createNote(Note note) async {
    return await _databaseHelper.insertNote(note);
  }

  static Future<List<Note>> getAllNotes() async {
    return await _databaseHelper.getNotes();
  }

  static Future<int> updateNote(Note note) async {
    return await _databaseHelper.updateNote(note);
  }
}
