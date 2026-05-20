import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application.dart';
import '../models/module.dart';

class ApplicationService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Helper method to fetch module details by code
  Future<Module?> _getModuleByCode(String moduleCode) async {
    if (moduleCode.isEmpty) return null;

    try {
      final response = await _client
          .from('modules')
          .select()
          .eq('module_code', moduleCode)
          .maybeSingle();

      if (response == null) return null;

      return Module(
        moduleCode: response['module_code'] ?? '',
        moduleName: response['module_name'] ?? '',
        academicLevel: response['academic_level'] ?? '',
      );
    } catch (e) {
      print('Error fetching module $moduleCode: $e');
      return null;
    }
  }

  /// Helper to map a raw Supabase row to an Application object
  Future<Application> _mapRowToApplication(Map<String, dynamic> data) async {
    final firstModuleDetails = await _getModuleByCode(
      data['first_module'] ?? '',
    );

    Module? secondModuleDetails;
    if (data['second_module'] != null &&
        data['second_module'].toString().isNotEmpty) {
      secondModuleDetails = await _getModuleByCode(data['second_module']);
    }

    return Application(
      // FIX 1: column is 'application_id', not 'id'
      applicationId: data['application_id']?.toString(),
      studentId: data['student_id'],
      firstModule:
          firstModuleDetails ??
          Module(
            moduleCode: data['first_module'] ?? '',
            moduleName: '',
            academicLevel: '',
          ),
      secondModule: secondModuleDetails,
      confirmedEligibility: data['confirmed_eligibility'] ?? false,
      status: data['status'] ?? 'Pending',
      timeOfApplication: DateTime.parse(data['time_of_application']),
    );
  }

  /// Insert a new application
  Future<Application> createApplication(Application app) async {
    if (app.studentId.isEmpty) {
      throw Exception(
        "Cannot save application: studentId is empty. "
        "Make sure the user is logged in before submitting.",
      );
    }

    final data = await _client
        .from('applications')
        .insert({
          'student_id': app.studentId,
          'first_module': app.firstModule.moduleCode,
          'second_module': app.secondModule?.moduleCode,
          'confirmed_eligibility': app.confirmedEligibility,
          'status': app.status,
          'time_of_application': app.timeOfApplication.toIso8601String(),
        })
        .select()
        .single();

    return _mapRowToApplication(data);
  }

  /// Fetch ALL applications (for admin)
  Future<List<Application>> getAllApplications() async {
    final response = await _client
        .from('applications')
        .select()
        .order('time_of_application', ascending: false);

    final List<Application> applications = [];
    for (var data in response as List) {
      applications.add(await _mapRowToApplication(data));
    }
    return applications;
  }

  /// Fetch applications for a student
  Future<List<Application>> getApplicationsByStudent(String studentId) async {
    if (studentId.isEmpty) return [];

    final response = await _client
        .from('applications')
        .select()
        .eq('student_id', studentId)
        .order('time_of_application', ascending: false);

    final List<Application> applications = [];
    for (var data in response as List) {
      applications.add(await _mapRowToApplication(data));
    }
    return applications;
  }

  /// Update application status
  Future<void> updateStatus(String applicationId, String status) async {
    // FIX 2: was .eq('id', ...) — correct column name is 'application_id'
    // FIX 3: added .select().single() so Supabase actually executes the update
    //         and throws if no row was matched (e.g. RLS blocking the write)
    await _client
        .from('applications')
        .update({'status': status})
        .eq('application_id', applicationId)
        .select()
        .single();
  }
}
