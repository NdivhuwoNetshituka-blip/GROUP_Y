/**
 * GROUP Y - TPG316C Student Assistant Application System
 *
 * Student Numbers and Names:
 *   215135458 - LE Lipali
 *   223013773 - NM Netshituka
 *   224004294 - B Linda
 *   221050663 - GR Kgwele
 *   222066543 - RG Madi
 *   224007421 - Y Mazamani
 *   224099468 - LE Letsie
 *   219002738 - LTBG Pule
 *   223060226 - NC Pali
 *   223007074 - T Zitha
 *
 * File: application_service.dart
 * Description: Service layer for application CRUD operations against Supabase.
 */

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application.dart';
import '../models/module.dart';

class ApplicationService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Insert a new application
  Future<Application> createApplication(Application app) async {
    final response = await _client.from('applications').insert({
      'student_id': app.studentId,
      'first_module': app.firstModule.moduleCode,
      'second_module': app.secondModule?.moduleCode,
      'confirmed_eligibility': app.confirmedEligibility,
      'status': app.status,
      'time_of_application': app.timeOfApplication.toIso8601String(),
    }).select();

    final data = response[0];
    return _mapToApplication(data);
  }

  /// Fetch applications for a student
  Future<List<Application>> getApplicationsByStudent(String studentId) async {
    final response = await _client
        .from('applications')
        .select()
        .eq('student_id', studentId);

    return (response as List).map((data) => _mapToApplication(data)).toList();
  }

  /// Fetch ALL applications (admin only)
  Future<List<Application>> getAllApplications() async {
    final response = await _client
        .from('applications')
        .select()
        .order('time_of_application', ascending: false);

    return (response as List).map((data) => _mapToApplication(data)).toList();
  }

  /// Update application status
  Future<void> updateStatus(String applicationId, String status) async {
    await _client
        .from('applications')
        .update({'status': status})
        .eq('id', applicationId);
  }

  /// Update the modules and eligibility of an existing application (student edit)
  Future<void> updateApplication(Application app) async {
    if (app.applicationId == null) return;
    await _client
        .from('applications')
        .update({
          'first_module': app.firstModule.moduleCode,
          'second_module': app.secondModule?.moduleCode,
          'confirmed_eligibility': app.confirmedEligibility,
        })
        .eq('id', app.applicationId!);
  }

  /// Delete an application by ID
  Future<void> deleteApplication(String applicationId) async {
    await _client.from('applications').delete().eq('id', applicationId);
  }

  /// Helper: turn a Supabase row into an Application object
  Application _mapToApplication(Map<String, dynamic> data) {
    return Application(
      applicationId: data['id'],
      studentId: data['student_id'],
      firstModule: Module(
        moduleCode: data['first_module'] ?? '',
        moduleName: '',
        academicLevel: '',
      ),
      secondModule: data['second_module'] != null
          ? Module(
              moduleCode: data['second_module'],
              moduleName: '',
              academicLevel: '',
            )
          : null,
      confirmedEligibility: data['confirmed_eligibility'] ?? false,
      status: data['status'] ?? 'Pending',
      timeOfApplication: DateTime.parse(data['time_of_application']),
    );
  }
}
