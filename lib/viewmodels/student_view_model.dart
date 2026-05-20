import 'package:flutter/material.dart';
import '../models/student.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentViewModel extends ChangeNotifier {
  final Student _student = Student(
    firstName: "",
    lastName: "",
    studentNumber: "",
    currentYear: "",
  );

  // Getters
  String get firstName => _student.firstName;
  String get lastName => _student.lastName;
  String get studentNumber => _student.studentNumber;
  String get currentYear => _student.currentYear;
  String? get idDocument => _student.idDocument;
  String? get academicTranscript => _student.academicTranscript;
  String? get cv => _student.cv;
  String? get proofOfRegistration => _student.proofOfRegistration;
  String? get matricCertificate => _student.matricCertificate;
  Student get student => _student;

  // Set studentId once
  void setStudentId(String studentId) {
    _student.studentId = studentId;
    notifyListeners();
  }

  // Update methods
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

  void updateMatricCertificate(String filePath) {
    _student.matricCertificate = filePath;
    notifyListeners();
  }

  void setStudentIdFromAuth() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _student.studentId = user.id;
      notifyListeners();
    }
  }
}
