import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/student.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'students.db');

    return await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE students(studentID TEXT PRIMARY KEY, name TEXT, programID TEXT, cgpa REAL)',
        );
      },
      version: 1,
    );
  }

  Future<bool> checkStudentExists(String studentID) async {
    final db = await database;
    final result = await db.query(
      'students',
      where: 'studentID = ?',
      whereArgs: [studentID],
    );
    return result.isNotEmpty;
  }

  Future<void> insertStudent(Student student) async {
    final db = await database;

    final exists = await checkStudentExists(student.studentID);
    if (exists) {
      throw Exception('Student ID already exists.');
    }

    await db.insert(
      'students',
      student.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Student>> students() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('students');

    return List.generate(maps.length, (i) {
      return Student(
        studentID: maps[i]['studentID'],
        name: maps[i]['name'],
        programID: maps[i]['programID'],
        cgpa: maps[i]['cgpa'],
      );
    });
  }

  Future<void> updateStudent(Student student) async {
    final db = await database;
    await db.update(
      'students',
      student.toMap(),
      where: 'studentID = ?',
      whereArgs: [student.studentID],
    );
  }

  Future<void> deleteStudent(String studentID) async {
    final db = await database;
    await db.delete(
      'students',
      where: 'studentID = ?',
      whereArgs: [studentID],
    );
  }
}
