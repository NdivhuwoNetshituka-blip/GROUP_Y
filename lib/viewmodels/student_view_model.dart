import 'package:flutter/material.dart';
import '../models/student.dart';

class StudentViewModel extends ChangeNotifier {
  final Student _student = Student(
    firstName: "",
    lastName: "",
    studentNumber: "",
    currentYear: "",
  );

  String get firstName => _student.firstName;
  String get lastName => _student.lastName;
  String get studentNumber => _student.studentNumber;
  String get currentYear => _student.currentYear;
  String? get idDocument => _student.idDocument;
  String? get academicTranscript => _student.academicTranscript;
  String? get cv => _student.cv;
  String? get proofOfRegistration => _student.proofOfRegistration;

  //Instead of an update method, I have a set method for the id because this
  //field is not meant to be updated. Only set once returned from Supabase
  void setStudentId(String studentId) {
    _student.studentId = studentId;
    notifyListeners();
  }

  void updateFirstName(String firstName) {
    _student.firstName = firstName;
    notifyListeners();
  }

  void updateLastName(String lastName) {
    _student.lastName = lastName;
    notifyListeners();
  }

  void updateStudentNumber(String studentNumber) {
    _student.studentNumber = studentNumber;
    notifyListeners();
  }

  void updateCurrentYear(String currentYear) {
    _student.currentYear = currentYear;
    notifyListeners();
  }

  void updateIdDocument(String filePath) {
    _student.idDocument = filePath;
    notifyListeners();
  }

  void updateAcademicTranscript(String filePath) {
    _student.academicTranscript = filePath;
    notifyListeners();
  }

  void updateCv(String filePath) {
    _student.cv = filePath;
    notifyListeners();
  }

  void updateProofOfRegistration(String filePath) {
    _student.proofOfRegistration = filePath;
    notifyListeners();
  }
}
