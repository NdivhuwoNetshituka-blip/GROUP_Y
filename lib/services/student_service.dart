import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student.dart';

class StudentService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch a student by ID
  Future<Student?> getStudentById(String studentId) async {
    try {
      final response = await _client
          .from('students')
          .select()
          .eq('id', studentId)
          .maybeSingle();

      if (response == null) return null;

      return Student(
        studentId: response['id'],
        firstName: response['first_name'] ?? "",
        lastName: response['last_name'] ?? "",
        studentNumber: response['student_number'] ?? "",
        currentYear: response['current_year'] ?? "",
        idDocument: response['id_document'],
        proofOfRegistration: response['proof_of_registration'],
        academicTranscript: response['academic_transcript'],
        cv: response['cv'],
        matricCertificate: response['matric_certificate'],
      );
    } catch (e) {
      print('Error getting student: $e');
      return null;
    }
  }

  /// Update student details
  Future<void> updateStudent(Student student) async {
    try {
      await _client
          .from('students')
          .update({
            'first_name': student.firstName,
            'last_name': student.lastName,
            'student_number': student.studentNumber,
            'current_year': student.currentYear,
            'id_document': student.idDocument,
            'proof_of_registration': student.proofOfRegistration,
            'academic_transcript': student.academicTranscript,
            'cv': student.cv,
            'matric_certificate': student.matricCertificate,
          })
          .eq('id', student.studentId!);
    } catch (e) {
      print('Error updating student: $e');
      rethrow;
    }
  }

  /// Create a new student
  Future<void> createStudent(Student student) async {
    try {
      await _client.from('students').insert({
        'id': student.studentId, // This must match auth.users id
        'first_name': student.firstName,
        'last_name': student.lastName,
        'student_number': student.studentNumber,
        'current_year': student.currentYear,
        'id_document': student.idDocument,
        'proof_of_registration': student.proofOfRegistration,
        'academic_transcript': student.academicTranscript,
        'cv': student.cv,
        'matric_certificate': student.matricCertificate,
      });
    } catch (e) {
      print('Error creating student: $e');
      rethrow;
    }
  }
}
