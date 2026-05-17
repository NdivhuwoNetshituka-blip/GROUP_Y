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

import '../../models/module.dart';
import '../../viewmodels/application_view_model.dart';

class ApplicationFormScreen extends StatefulWidget {
  const ApplicationFormScreen({super.key});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Hardcoded module catalog — replace with Supabase fetch later if needed
  final List<Module> _allModules = [
    Module(
      moduleCode: 'PRG116C',
      moduleName: 'Programming 1A',
      academicLevel: '1',
    ),
    Module(
      moduleCode: 'PRG126C',
      moduleName: 'Programming 1B',
      academicLevel: '1',
    ),
    Module(
      moduleCode: 'WPG216C',
      moduleName: 'Web Programming',
      academicLevel: '2',
    ),
    Module(
      moduleCode: 'OOP216C',
      moduleName: 'Object-Oriented Programming',
      academicLevel: '2',
    ),
    Module(
      moduleCode: 'TPG316C',
      moduleName: 'Technical Programming III',
      academicLevel: '3',
    ),
    Module(
      moduleCode: 'PRJ316C',
      moduleName: 'Project Management',
      academicLevel: '3',
    ),
  ];

  String? _firstLevel;
  Module? _firstModule;
  bool _addSecondModule = false;
  String? _secondLevel;
  Module? _secondModule;
  bool _eligibilityConfirmed = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate if editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<ApplicationViewModel>(context, listen: false);
      if (vm.applicationId != null) {
        if (vm.firstModule.moduleCode.isNotEmpty) {
          _firstModule = _allModules.firstWhere(
            (m) => m.moduleCode == vm.firstModule.moduleCode,
            orElse: () => _allModules.first,
          );
          _firstLevel = _firstModule!.academicLevel;
        }
        if (vm.secondModule != null) {
          _addSecondModule = true;
          _secondModule = _allModules.firstWhere(
            (m) => m.moduleCode == vm.secondModule!.moduleCode,
            orElse: () => _allModules.first,
          );
          _secondLevel = _secondModule!.academicLevel;
        }
        _eligibilityConfirmed = vm.confirmedEligibility;
        setState(() {});
      }
    });
  }

  List<Module> _modulesForLevel(String? level, {Module? exclude}) {
    if (level == null) return [];
    return _allModules
        .where(
          (m) =>
              m.academicLevel == level && m.moduleCode != exclude?.moduleCode,
        )
        .toList();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_firstModule == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a first module.')),
      );
      return;
    }
    if (!_eligibilityConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must confirm you meet the minimum requirements.'),
        ),
      );
      return;
    }

    final vm = Provider.of<ApplicationViewModel>(context, listen: false);
    vm.updateFirstModule(_firstModule!);
    vm.updateSecondModule(_addSecondModule ? _secondModule : null);
    vm.updateEligibility(_eligibilityConfirmed);
    vm.updateTimeOfApplication(DateTime.now());

    final isEdit = vm.applicationId != null;
    final success = isEdit
        ? await vm.saveEdits()
        : await vm.submitApplication();

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'Application updated successfully.'
                : 'Application submitted successfully.',
          ),
        ),
      );
      // Reload list for the home screen
      if (vm.studentId.isNotEmpty) {
        await vm.loadApplicationsForStudent(vm.studentId);
      }
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage ?? 'Something went wrong.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ApplicationViewModel>(
          builder: (_, vm, __) => Text(
            vm.applicationId != null ? 'Edit Application' : 'New Application',
          ),
        ),
      ),
      body: Consumer<ApplicationViewModel>(
        builder: (context, vm, _) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Module 1',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _firstLevel,
                  decoration: const InputDecoration(
                    labelText: 'Academic level',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: '1',
                      child: Text('First-year modules'),
                    ),
                    DropdownMenuItem(
                      value: '2',
                      child: Text('Second-year modules'),
                    ),
                    DropdownMenuItem(
                      value: '3',
                      child: Text('Third-year modules'),
                    ),
                  ],
                  validator: (v) => v == null ? 'Please pick a level' : null,
                  onChanged: (v) => setState(() {
                    _firstLevel = v;
                    _firstModule = null;
                  }),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Module>(
                  initialValue: _firstModule,
                  decoration: const InputDecoration(
                    labelText: 'Module',
                    border: OutlineInputBorder(),
                  ),
                  items: _modulesForLevel(_firstLevel)
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text('${m.moduleCode} - ${m.moduleName}'),
                        ),
                      )
                      .toList(),
                  validator: (v) => v == null ? 'Please pick a module' : null,
                  onChanged: (v) => setState(() => _firstModule = v),
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text('Apply for a second module'),
                  subtitle: const Text('Optional — maximum of 2 modules'),
                  value: _addSecondModule,
                  onChanged: (v) => setState(() {
                    _addSecondModule = v;
                    if (!v) {
                      _secondLevel = null;
                      _secondModule = null;
                    }
                  }),
                ),
                if (_addSecondModule) ...[
                  const Text(
                    'Module 2',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _secondLevel,
                    decoration: const InputDecoration(
                      labelText: 'Academic level',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: '1',
                        child: Text('First-year modules'),
                      ),
                      DropdownMenuItem(
                        value: '2',
                        child: Text('Second-year modules'),
                      ),
                      DropdownMenuItem(
                        value: '3',
                        child: Text('Third-year modules'),
                      ),
                    ],
                    validator: (v) => v == null ? 'Please pick a level' : null,
                    onChanged: (v) => setState(() {
                      _secondLevel = v;
                      _secondModule = null;
                    }),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Module>(
                    initialValue: _secondModule,
                    decoration: const InputDecoration(
                      labelText: 'Module',
                      border: OutlineInputBorder(),
                    ),
                    items: _modulesForLevel(_secondLevel, exclude: _firstModule)
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text('${m.moduleCode} - ${m.moduleName}'),
                          ),
                        )
                        .toList(),
                    validator: (v) => v == null ? 'Please pick a module' : null,
                    onChanged: (v) => setState(() => _secondModule = v),
                  ),
                ],
                const SizedBox(height: 24),
                CheckboxListTile(
                  title: const Text(
                    'I confirm I meet the minimum requirements for the selected modules.',
                  ),
                  value: _eligibilityConfirmed,
                  onChanged: (v) =>
                      setState(() => _eligibilityConfirmed = v ?? false),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: vm.isLoading ? null : _submit,
                    child: vm.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            vm.applicationId != null
                                ? 'Save changes'
                                : 'Submit application',
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
