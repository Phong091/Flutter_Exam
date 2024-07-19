import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../model/student.dart';

class StudentView extends StatefulWidget {
  const StudentView({super.key});

  @override
  State<StudentView> createState() => _StudentViewState();
}

class _StudentViewState extends State<StudentView> {
  final _studentIDController = TextEditingController();
  final _nameController = TextEditingController();
  final _programIDController = TextEditingController();
  final _cgpaController = TextEditingController();

  final _databaseHelper = DatabaseHelper();

  List<Student> _studentList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('CRUD App')),
        backgroundColor: const Color(0xffffc43d),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _studentIDController,
              decoration: const InputDecoration(labelText: 'Student ID'),
            ),
            TextField(
              controller: _programIDController,
              decoration: const InputDecoration(labelText: 'Study Program ID'),
            ),
            TextField(
              controller: _cgpaController,
              decoration: const InputDecoration(labelText: 'CGPA'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _createStudent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff00b35b),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create'),
                ),
                ElevatedButton(
                  onPressed: _readStudents,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff3291ed),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Read'),
                ),
                ElevatedButton(
                  onPressed: _updateStudent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffff9930),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Update'),
                ),
                ElevatedButton(
                  onPressed: _deleteStudent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffff3f3c),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildStudentTable()),
          ],
        ),
      ),
    );
  }

  Future<void> _createStudent() async {
    if (_validateInputs()) {
      final student = Student(
        studentID: _studentIDController.text,
        name: _nameController.text,
        programID: _programIDController.text,
        cgpa: double.parse(_cgpaController.text),
      );
      try {
        await _databaseHelper.insertStudent(student);
        _clearInputs();
        _readStudents();
      } catch (e) {
        _showErrorDialog('Student with this ID already exists!');
      }
    } else {
      _showErrorDialog('Please fill all fields correctly.');
    }
  }

  Future<void> _readStudents() async {
    final students = await _databaseHelper.students();
    setState(() {
      _studentList = students;
    });
  }

  Future<void> _updateStudent() async {
    if (_validateInputs()) {
      final student = Student(
        studentID: _studentIDController.text,
        name: _nameController.text,
        programID: _programIDController.text,
        cgpa: double.parse(_cgpaController.text),
      );

      await _databaseHelper.updateStudent(student);
      _clearInputs();
      _readStudents();
    } else {
      _showErrorDialog('Please fill all fields correctly.');
    }
  }

  Future<void> _deleteStudent() async {
    final studentID = _studentIDController.text;
    if (studentID.isNotEmpty) {
      await _databaseHelper.deleteStudent(studentID);
      _clearInputs();
      _readStudents();
    } else {
      _showErrorDialog('Please enter a Student ID.');
    }
  }

  bool _validateInputs() {
    if (_studentIDController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _programIDController.text.isEmpty ||
        _cgpaController.text.isEmpty ||
        double.tryParse(_cgpaController.text) == null) {
      return false;
    }
    return true;
  }

  void _clearInputs() {
    _studentIDController.clear();
    _nameController.clear();
    _programIDController.clear();
    _cgpaController.clear();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStudentTable() {
    return ListView(
      children: [
        // Table header
        Container(
          color: Colors.white,
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                children: [
                  _buildTableCell('Name', isHeader: true),
                  _buildTableCell('Student ID', isHeader: true),
                  _buildTableCell('Program ID', isHeader: true),
                  _buildTableCell('CGPA', isHeader: true),
                ],
              ),
            ],
          ),
        ),
        // Table rows
        ..._studentList.map((student) {
          return InkWell(
            onTap: () => _fillInputsForUpdate(student),
            child: Container(
              color: Colors.white,
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(2),
                },
                children: [
                  TableRow(
                    children: [
                      _buildTableCell(student.name),
                      _buildTableCell(student.studentID),
                      _buildTableCell(student.programID),
                      _buildTableCell(student.cgpa.toString()),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.black : Colors.grey[700],
        ),
      ),
    );
  }

  void _fillInputsForUpdate(Student student) {
    _studentIDController.text = student.studentID;
    _nameController.text = student.name;
    _programIDController.text = student.programID;
    _cgpaController.text = student.cgpa.toString();
  }
}
