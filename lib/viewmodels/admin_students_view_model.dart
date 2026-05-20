import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application.dart';
import '../models/student.dart';
import '../services/application_service.dart';
import '../services/student_service.dart';

class AppliedStudent {
  final Student student;
  final List<Application> applications;
  final int applicationCount;
  final String latestStatus;

  AppliedStudent({required this.student, required this.applications})
    : applicationCount = applications.length,
      latestStatus = applications.isNotEmpty
          ? applications.first.status
          : 'No applications';
}

class AdminStudentsViewModel extends ChangeNotifier {
  final ApplicationService _applicationService = ApplicationService();
  final StudentService _studentService = StudentService();
  final SupabaseClient _supabase = Supabase.instance.client;

  List<AppliedStudent> _appliedStudents = [];
  List<AppliedStudent> get appliedStudents => _appliedStudents;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadAppliedStudents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final allApplications = await _applicationService.getAllApplications();

      final Map<String, List<Application>> appsByStudent = {};
      for (var app in allApplications) {
        appsByStudent.putIfAbsent(app.studentId, () => []).add(app);
      }

      final List<AppliedStudent> result = [];
      for (var entry in appsByStudent.entries) {
        final studentId = entry.key;
        final studentApps = entry.value;
        studentApps.sort(
          (a, b) => b.timeOfApplication.compareTo(a.timeOfApplication),
        );

        // Fetch student record from Supabase (real data)
        Student? student = await _studentService.getStudentById(studentId);

        // Only create a placeholder if the student record does NOT exist at all
        if (student == null) {
          final userData = await _supabase
              .from('users')
              .select('email')
              .eq('id', studentId)
              .maybeSingle();
          String email = userData?['email'] ?? 'unknown@example.com';
          String emailPrefix = email.split('@').first;

          student = Student(
            studentId: studentId,
            firstName: emailPrefix,
            lastName: '',
            studentNumber: 'Not set',
            currentYear: 'Not set',
          );
        }
        // Otherwise, keep the existing student data as is (no overwriting)

        result.add(AppliedStudent(student: student, applications: studentApps));
      }

      result.sort((a, b) {
        final aDate = a.applications.isNotEmpty
            ? a.applications.first.timeOfApplication
            : DateTime(0);
        final bDate = b.applications.isNotEmpty
            ? b.applications.first.timeOfApplication
            : DateTime(0);
        return bDate.compareTo(aDate);
      });

      _appliedStudents = result;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
