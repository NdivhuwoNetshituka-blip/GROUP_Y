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
 * File: home_screen.dart
 * Description: Student home screen - shows their application status and access to manage it.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/application.dart';
import '../../routes/route_manager.dart';
import '../../viewmodels/application_view_model.dart';
import '../../viewmodels/auth_view_model.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadApplications());
  }

  Future<void> _loadApplications() async {
    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    final appVm = Provider.of<ApplicationViewModel>(context, listen: false);
    if (authVm.currentUser != null) {
      await appVm.loadApplicationsForStudent(authVm.currentUser!.id);
    }
  }

  Future<void> _logout() async {
    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    await authVm.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteManager.logInScreen,
      (_) => false,
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Application'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Consumer<ApplicationViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.applications.isEmpty) {
            return RefreshIndicator(
              onRefresh: _loadApplications,
              child: ListView(
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.assignment_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'You have not submitted\nan application yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Tap the Apply button below to submit your Student Assistant application.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Student has an application — show the summary
          final Application app = vm.applications.first;
          return RefreshIndicator(
            onRefresh: _loadApplications,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Status'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(app.status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _statusColor(app.status)),
                      ),
                      child: Text(
                        app.status,
                        style: TextStyle(
                          color: _statusColor(app.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.book_outlined),
                    title: const Text('First module'),
                    subtitle: Text(app.firstModule.moduleCode),
                  ),
                ),
                if (app.secondModule != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.book_outlined),
                      title: const Text('Second module'),
                      subtitle: Text(app.secondModule!.moduleCode),
                    ),
                  ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: const Text('Submitted on'),
                    subtitle: Text(
                      '${app.timeOfApplication.day}/${app.timeOfApplication.month}/${app.timeOfApplication.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.visibility),
                  label: const Text('View / Manage application'),
                  onPressed: () {
                    vm.loadIntoForm(app);
                    Navigator.pushNamed(
                      context,
                      RouteManager.applicationDetailScreen,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<ApplicationViewModel>(
        builder: (context, vm, _) {
          if (vm.applications.isNotEmpty) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () {
              vm.resetForm();
              final authVm = Provider.of<AuthViewModel>(context, listen: false);
              if (authVm.currentUser != null) {
                vm.setStudentId(authVm.currentUser!.id);
              }
              Navigator.pushNamed(context, RouteManager.applicationFormScreen);
            },
            icon: const Icon(Icons.add),
            label: const Text('Apply'),
          );
        },
      ),
    );
  }
}
