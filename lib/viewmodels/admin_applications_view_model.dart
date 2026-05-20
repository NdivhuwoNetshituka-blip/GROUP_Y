import 'package:flutter/material.dart';
import '../models/application.dart';
import '../services/application_service.dart';

class AdminApplicationsViewModel extends ChangeNotifier {
  final ApplicationService _service = ApplicationService();

  List<Application> _applications = [];
  List<Application> get applications => _applications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadAllApplications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _applications = await _service.getAllApplications();
      print('✅ Loaded ${_applications.length} applications'); // Debug log
    } catch (e) {
      print('❌ Error loading applications: $e'); // Debug log
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateApplicationStatus(
    String applicationId,
    String status,
  ) async {
    print(
      '🔵 Updating application $applicationId to status: $status',
    ); // Debug log

    try {
      await _service.updateStatus(applicationId, status);
      print('✅ Status updated successfully'); // Debug log

      // Update local list
      final index = _applications.indexWhere(
        (a) => a.applicationId == applicationId,
      );
      if (index != -1) {
        _applications[index].status = status;
        notifyListeners();
        print(
          '🔄 UI refreshed, new status: ${_applications[index].status}',
        ); // Debug log
      } else {
        print('⚠️ Application not found in local list'); // Debug log
      }
    } catch (e) {
      print('❌ Error updating status: $e'); // Debug log
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
