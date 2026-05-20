import 'package:flutter/material.dart';
import '../models/application.dart';
import '../models/module.dart';
import '../services/application_service.dart';

class ApplicationViewModel extends ChangeNotifier {
  final ApplicationService _service = ApplicationService();

  Application _application = Application(
    studentId: "",
    firstModule: Module(moduleCode: "", moduleName: "", academicLevel: ""),
    confirmedEligibility: false,
    timeOfApplication: DateTime.now(),
  );

  Application get application => _application;

  // Getters
  String? get applicationId => _application.applicationId;
  String get studentId => _application.studentId;
  Module get firstModule => _application.firstModule;
  Module? get secondModule => _application.secondModule;
  bool get confirmedEligibility => _application.confirmedEligibility;
  String get status => _application.status;
  DateTime get timeOfApplication => _application.timeOfApplication;

  // Local state updates
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

  // Supabase integration via ApplicationService
  Future<void> saveApplication() async {
    final savedApp = await _service.createApplication(_application);
    _application = savedApp;
    notifyListeners();
  }

  Future<List<Application>> fetchApplications(String studentId) async {
    return await _service.getApplicationsByStudent(studentId);
  }

  Future<void> changeStatus(String applicationId, String status) async {
    await _service.updateStatus(applicationId, status);
    notifyListeners();
  }
}
