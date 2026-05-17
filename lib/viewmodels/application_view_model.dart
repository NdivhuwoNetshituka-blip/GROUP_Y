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

import '../models/application.dart';
import '../models/module.dart';
import '../services/application_service.dart';

class ApplicationViewModel extends ChangeNotifier {
  final ApplicationService _service = ApplicationService();

  // ---------- In-progress application (used by the form) ----------
  Application _application = Application(
    studentId: "",
    firstModule: Module(moduleCode: "", moduleName: "", academicLevel: ""),
    confirmedEligibility: false,
    timeOfApplication: DateTime.now(),
  );

  // ---------- Lists & loading state ----------
  List<Application> _applications = [];
  List<Application> get applications => _applications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ---------- In-progress application getters/setters ----------
  String? get applicationId => _application.applicationId;
  String get studentId => _application.studentId;
  Module get firstModule => _application.firstModule;
  Module? get secondModule => _application.secondModule;
  bool get confirmedEligibility => _application.confirmedEligibility;
  String get status => _application.status;
  DateTime get timeOfApplication => _application.timeOfApplication;

  void setApplicationId(String applicationId) {
    _application.applicationId = applicationId;
    notifyListeners();
  }

  void setStudentId(String studentId) {
    _application.studentId = studentId;
    notifyListeners();
  }

  void updateFirstModule(Module module) {
    _application.firstModule = module;
    notifyListeners();
  }

  void updateSecondModule(Module? module) {
    _application.secondModule = module;
    notifyListeners();
  }

  void updateEligibility(bool eligibility) {
    _application.confirmedEligibility = eligibility;
    notifyListeners();
  }

  void updateStatus(String status) {
    _application.status = status;
    notifyListeners();
  }

  void updateTimeOfApplication(DateTime dateTime) {
    _application.timeOfApplication = dateTime;
    notifyListeners();
  }

  /// Reset the in-progress application (used after submit or when starting fresh)
  void resetForm() {
    _application = Application(
      studentId: _application.studentId, // keep the student id
      firstModule: Module(moduleCode: "", moduleName: "", academicLevel: ""),
      confirmedEligibility: false,
      timeOfApplication: DateTime.now(),
    );
    notifyListeners();
  }

  /// Load an existing application into the form for editing
  void loadIntoForm(Application app) {
    _application = Application(
      applicationId: app.applicationId,
      studentId: app.studentId,
      firstModule: app.firstModule,
      secondModule: app.secondModule,
      confirmedEligibility: app.confirmedEligibility,
      status: app.status,
      timeOfApplication: app.timeOfApplication,
    );
    notifyListeners();
  }

  // ---------- CRUD operations ----------

  /// Fetch all applications for a specific student
  Future<void> loadApplicationsForStudent(String studentId) async {
    _setLoading(true);
    try {
      _applications = await _service.getApplicationsByStudent(studentId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  /// Fetch all applications (admin)
  Future<void> loadAllApplications() async {
    _setLoading(true);
    try {
      _applications = await _service.getAllApplications();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  /// Submit the current in-progress application
  Future<bool> submitApplication() async {
    _setLoading(true);
    try {
      final saved = await _service.createApplication(_application);
      _application.applicationId = saved.applicationId;
      _errorMessage = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Save edits to an existing application
  Future<bool> saveEdits() async {
    _setLoading(true);
    try {
      await _service.updateApplication(_application);
      _errorMessage = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Admin approves/rejects an application
  Future<bool> changeStatus(String applicationId, String newStatus) async {
    _setLoading(true);
    try {
      await _service.updateStatus(applicationId, newStatus);
      // Update local list as well
      final index = _applications.indexWhere(
        (a) => a.applicationId == applicationId,
      );
      if (index != -1) {
        _applications[index].status = newStatus;
      }
      _errorMessage = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Delete an application
  Future<bool> deleteApplication(String applicationId) async {
    _setLoading(true);
    try {
      await _service.deleteApplication(applicationId);
      _applications.removeWhere((a) => a.applicationId == applicationId);
      _errorMessage = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ---------- Helper ----------
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
