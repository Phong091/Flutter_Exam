class Student {
  String studentID;
  String name;
  String programID;
  double cgpa;

  Student({required this.studentID, required this.name, required this.programID, required this.cgpa});

  Map<String, dynamic> toMap() {
    return {
      'studentID': studentID,
      'name': name,
      'programID': programID,
      'cgpa': cgpa,
    };
  }
}