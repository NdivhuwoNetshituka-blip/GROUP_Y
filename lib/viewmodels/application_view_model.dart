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
 * File: application_view_model.dart
 * Description: ViewModel for managing application state and CRUD operations.
 */

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application.dart';
import '../services/application_service.dart';

class ApplicationsViewModel extends ChangeNotifier {
  final ApplicationService _service = ApplicationService();
  final SupabaseClient _client = Supabase.instance.client;

  List<Application> _applications = [];
  List<Application> get applications => _applications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  RealtimeChannel? _statusChannel;

  // Track whether we've already subscribed so loadApplications can be called
  // multiple times (e.g. after submitting a new application) without spinning
  // up duplicate Realtime channels.
  bool _subscribed = false;

  /// Fetch all applications for a student.
  /// Call subscribeToStatusUpdates() separately, once, from initState.
  Future<void> loadApplications(String studentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _applications = await _service.getApplicationsByStudent(studentId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Subscribe to Realtime status updates for this student.
  /// Must be called exactly once — from initState / _loadEverything,
  /// NOT from didChangeDependencies or loadApplications.
  void subscribeToStatusUpdates(String studentId) {
    if (_subscribed) return; // guard: never create a second channel
    _subscribed = true;

    _statusChannel = _client
        .channel('applications:student:$studentId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'applications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'student_id',
            value: studentId,
          ),
          callback: (payload) {
            final updatedRow = payload.newRecord;
            final updatedId = updatedRow['application_id']?.toString();
            final updatedStatus = updatedRow['status']?.toString();

            if (updatedId == null || updatedStatus == null) return;

            final index = _applications.indexWhere(
              (a) => a.applicationId == updatedId,
            );
            if (index != -1 && _applications[index].status != updatedStatus) {
              _applications[index].status = updatedStatus;
              notifyListeners(); // only fires when status actually changed
            }
          },
        )
        .subscribe();
  }

  /// Submit a new application
  Future<void> addApplication(Application app) async {
    try {
      final newApp = await _service.createApplication(app);
      _applications.add(newApp);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Update status of an application (student-side, if ever needed)
  Future<void> updateStatus(String applicationId, String status) async {
    try {
      await _service.updateStatus(applicationId, status);
      final index = _applications.indexWhere(
        (a) => a.applicationId == applicationId,
      );
      if (index != -1) {
        _applications[index].status = status;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _statusChannel?.unsubscribe();
    super.dispose();
  }
}
