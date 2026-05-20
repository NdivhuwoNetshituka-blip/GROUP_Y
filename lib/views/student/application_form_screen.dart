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
 * File: application_form_screen.dart
 * Description: Form for creating or editing a Student Assistant application.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/module.dart';
import '../../models/student.dart'; // ✅ ADDED
import '../../viewmodels/application_view_model.dart';
import '../../viewmodels/applications_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/student_view_model.dart';
import '../../services/student_service.dart';

class ApplicationFormScreen extends StatefulWidget {
  const ApplicationFormScreen({super.key});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstModuleCodeController =
      TextEditingController();
  final TextEditingController firstModuleNameController =
      TextEditingController();
  final TextEditingController firstModuleLevelController =
      TextEditingController();

  final TextEditingController secondModuleCodeController =
      TextEditingController();
  final TextEditingController secondModuleNameController =
      TextEditingController();
  final TextEditingController secondModuleLevelController =
      TextEditingController();

  bool eligibilityConfirmed = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    firstModuleCodeController.dispose();
    firstModuleNameController.dispose();
    firstModuleLevelController.dispose();
    secondModuleCodeController.dispose();
    secondModuleNameController.dispose();
    secondModuleLevelController.dispose();
    super.dispose();
  }

  /// Resolve the current student's UUID synchronously.
  String? _resolveStudentId(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (authViewModel.currentUser != null &&
        authViewModel.currentUser!.id.isNotEmpty) {
      return authViewModel.currentUser!.id;
    }

    final supabaseUser = Supabase.instance.client.auth.currentUser;
    if (supabaseUser != null) {
      return supabaseUser.id;
    }

    final studentViewModel = Provider.of<StudentViewModel>(
      context,
      listen: false,
    );
    final sid = studentViewModel.student.studentId;
    if (sid != null && sid.isNotEmpty) {
      return sid;
    }

    return null;
  }

  /// Ensure a student record exists for this user ID; create minimal one if missing.
  Future<void> _ensureStudentRecordExists(String studentId) async {
    final studentService = StudentService();
    final existing = await studentService.getStudentById(studentId);
    if (existing == null) {
      final newStudent = Student(
        studentId: studentId,
        firstName: '',
        lastName: '',
        studentNumber: '',
        currentYear: '',
      );
      await studentService.createStudent(newStudent);
    }
  }

  Future<void> submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    if (!eligibilityConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please confirm your eligibility before submitting."),
        ),
      );
      return;
    }

    final studentId = _resolveStudentId(context);
    if (studentId == null || studentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "You must be logged in to submit an application. Please log in again.",
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // ✅ Create minimal student record if it doesn't exist
    try {
      await _ensureStudentRecordExists(studentId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating student record: $e")),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    final appViewModel = Provider.of<ApplicationViewModel>(
      context,
      listen: false,
    );
    final appsViewModel = Provider.of<ApplicationsViewModel>(
      context,
      listen: false,
    );

    appViewModel.setStudentId(studentId);

    final firstModule = Module(
      moduleCode: firstModuleCodeController.text.trim(),
      moduleName: firstModuleNameController.text.trim(),
      academicLevel: firstModuleLevelController.text.trim(),
    );

    Module? secondModule;
    if (secondModuleCodeController.text.trim().isNotEmpty &&
        secondModuleNameController.text.trim().isNotEmpty &&
        secondModuleLevelController.text.trim().isNotEmpty) {
      secondModule = Module(
        moduleCode: secondModuleCodeController.text.trim(),
        moduleName: secondModuleNameController.text.trim(),
        academicLevel: secondModuleLevelController.text.trim(),
      );
    }

    appViewModel.updateFirstModule(firstModule);
    appViewModel.updateSecondModule(secondModule);
    appViewModel.updateEligibility(eligibilityConfirmed);
    appViewModel.updateTimeOfApplication(DateTime.now());

    try {
      await appViewModel.saveApplication();
      await appsViewModel.loadApplications(studentId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Application submitted successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving application: $e")));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Submit Application")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "First Module",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: firstModuleCodeController,
                decoration: const InputDecoration(
                  labelText: "Module Code",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter module code" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: firstModuleNameController,
                decoration: const InputDecoration(
                  labelText: "Module Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter module name" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: firstModuleLevelController,
                decoration: const InputDecoration(
                  labelText: "Academic Level",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Enter academic level"
                    : null,
              ),
              const SizedBox(height: 24),
              const Text(
                "Second Module (Optional)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: secondModuleCodeController,
                decoration: const InputDecoration(
                  labelText: "Module Code",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: secondModuleNameController,
                decoration: const InputDecoration(
                  labelText: "Module Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: secondModuleLevelController,
                decoration: const InputDecoration(
                  labelText: "Academic Level",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              CheckboxListTile(
                title: const Text("Confirm Eligibility"),
                value: eligibilityConfirmed,
                onChanged: (val) {
                  setState(() {
                    eligibilityConfirmed = val ?? false;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () => submitForm(context),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Submit Application"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
