import 'package:supabase_flutter/supabase_flutter.dart';

class AdminApplicationService {
  final SupabaseClient _client;

  AdminApplicationService(this._client);

  /// Update application status and eligibility
  Future<void> updateApplicationStatus(
    String applicationId,
    String newStatus,
  ) async {
    try {
      // 1. Update the application status in Supabase
      final response = await _client
          .from('applications')
          .update({'status': newStatus})
          .eq('application_id', applicationId);

      if (response.error != null) {
        throw response.error!;
      }

      // 2. Update eligibility in students table depending on status
      if (newStatus.toLowerCase() == 'approved') {
        await _updateEligibility(applicationId, true);
      } else if (newStatus.toLowerCase() == 'rejected') {
        await _updateEligibility(applicationId, false);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Helper: update eligibility in students table
  Future<void> _updateEligibility(String applicationId, bool isEligible) async {
    // Fetch the student_id from the applications table
    final appRow = await _client
        .from('applications')
        .select('student_id')
        .eq('application_id', applicationId)
        .single();

    final studentId = appRow['student_id'];

    // Update eligibility in students table
    final response = await _client
        .from('students')
        .update({'eligible': isEligible})
        .eq('student_id', studentId);

    if (response.error != null) {
      throw response.error!;
    }
  }
}
