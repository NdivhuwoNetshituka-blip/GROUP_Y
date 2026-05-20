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
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/applications_view_model.dart';
import '../../viewmodels/student_view_model.dart';
import '../../routes/route_manager.dart';
import '../../services/student_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEverything());
  }

  // REMOVED: didChangeDependencies override.
  // It was calling _refreshApplicationsOnly() on every Provider notification,
  // which re-created the Realtime channel on each notifyListeners() call from
  // that same channel — a feedback loop that caused the flickering.
  // The Realtime subscription in ApplicationsViewModel handles live updates
  // automatically; there is no need to re-fetch here.

  String? _resolveStudentId(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (authViewModel.currentUser != null &&
        authViewModel.currentUser!.id.isNotEmpty) {
      return authViewModel.currentUser!.id;
    }
    return Supabase.instance.client.auth.currentUser?.id;
  }

  Future<void> _loadEverything() async {
    final studentViewModel = Provider.of<StudentViewModel>(
      context,
      listen: false,
    );
    final appsViewModel = Provider.of<ApplicationsViewModel>(
      context,
      listen: false,
    );

    final studentId = _resolveStudentId(context);
    if (studentId == null || studentId.isEmpty) {
      setState(() => _initialized = true);
      return;
    }

    studentViewModel.setStudentId(studentId);

    final service = StudentService();

    try {
      final existing = await service.getStudentById(studentId);
      if (existing == null) {
        await service.createStudent(studentViewModel.student);
      } else {
        studentViewModel.updateFirstName(existing.firstName);
        studentViewModel.updateLastName(existing.lastName);
        studentViewModel.updateStudentNumber(existing.studentNumber);
        studentViewModel.updateCurrentYear(existing.currentYear);
        if (existing.idDocument != null) {
          studentViewModel.updateIdDocument(existing.idDocument!);
        }
        if (existing.proofOfRegistration != null) {
          studentViewModel.updateProofOfRegistration(
            existing.proofOfRegistration!,
          );
        }
        if (existing.academicTranscript != null) {
          studentViewModel.updateAcademicTranscript(
            existing.academicTranscript!,
          );
        }
        if (existing.cv != null) studentViewModel.updateCv(existing.cv!);
        if (existing.matricCertificate != null) {
          studentViewModel.updateMatricCertificate(existing.matricCertificate!);
        }
      }

      // Load applications first, then subscribe exactly once.
      await appsViewModel.loadApplications(studentId);
      appsViewModel.subscribeToStatusUpdates(studentId); // called once, here
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading data: $e")));
    } finally {
      if (mounted) setState(() => _initialized = true);
    }
  }

  // Manual pull-to-refresh: re-fetches data from Supabase without
  // touching the Realtime subscription (still alive and guarded by _subscribed).
  Future<void> _refresh() async {
    final studentId = _resolveStudentId(context);
    if (studentId == null || studentId.isEmpty) return;

    final appsViewModel = Provider.of<ApplicationsViewModel>(
      context,
      listen: false,
    );
    setState(() => _initialized = false);
    await appsViewModel.loadApplications(studentId);
    if (mounted) setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final appsViewModel = Provider.of<ApplicationsViewModel>(context);
    final studentViewModel = Provider.of<StudentViewModel>(context);

    final currentUser = authViewModel.currentUser;
    final supabaseUser = Supabase.instance.client.auth.currentUser;
    final isLoggedIn = currentUser != null || supabaseUser != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Home"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authViewModel.signOut();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, "/login");
            },
          ),
        ],
      ),
      body: !isLoggedIn
          ? const Center(child: Text("No user logged in"))
          : !_initialized
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student Info
                    Card(
                      child: ListTile(
                        title: Text(
                          "${studentViewModel.firstName} ${studentViewModel.lastName}"
                                  .trim()
                                  .isEmpty
                              ? "(No name yet)"
                              : "${studentViewModel.firstName} ${studentViewModel.lastName}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Student Number: ${studentViewModel.studentNumber}",
                            ),
                            Text(
                              "Year of Study: ${studentViewModel.currentYear}",
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            await Navigator.pushNamed(
                              context,
                              RouteManager.editStudentProfile,
                            );
                            _refresh();
                          },
                          child: const Text("Edit Info"),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Documents Section
                    const Text("Documents", style: TextStyle(fontSize: 18)),
                    Card(
                      child: Column(
                        children: [
                          _buildDocStatus(
                            "ID Document",
                            studentViewModel.idDocument,
                          ),
                          _buildDocStatus(
                            "Proof of Registration",
                            studentViewModel.proofOfRegistration,
                          ),
                          _buildDocStatus(
                            "Academic Transcript",
                            studentViewModel.academicTranscript,
                          ),
                          _buildDocStatus("CV", studentViewModel.cv),
                          _buildDocStatus(
                            "Matric Certificate",
                            studentViewModel.matricCertificate,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Applications Section
                    const Text("Applications", style: TextStyle(fontSize: 18)),
                    appsViewModel.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : appsViewModel.errorMessage != null
                        ? Text("Error: ${appsViewModel.errorMessage}")
                        : appsViewModel.applications.isEmpty
                        ? const Text("No applications yet")
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: appsViewModel.applications.length,
                            itemBuilder: (context, index) {
                              final app = appsViewModel.applications[index];
                              Color statusColor;
                              switch (app.status.toLowerCase()) {
                                case 'approved':
                                  statusColor = Colors.green;
                                  break;
                                case 'rejected':
                                  statusColor = Colors.red;
                                  break;
                                default:
                                  statusColor = Colors.orange;
                              }

                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: statusColor.withOpacity(
                                      0.2,
                                    ),
                                    child: Icon(
                                      Icons.description,
                                      color: statusColor,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    "Application: ${app.firstModule.moduleCode}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Module: ${app.firstModule.moduleName}",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          "Status: ${app.status}",
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _formatDate(app.timeOfApplication),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Icon(
                                        app.status.toLowerCase() == 'approved'
                                            ? Icons.check_circle
                                            : app.status.toLowerCase() ==
                                                  'rejected'
                                            ? Icons.cancel
                                            : Icons.pending,
                                        color: statusColor,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                  onTap: () {},
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                RouteManager.applicationFormScreen,
              );
              // Only re-fetch the list — subscription is already live
              final studentId = _resolveStudentId(context);
              if (studentId != null && studentId.isNotEmpty) {
                Provider.of<ApplicationsViewModel>(
                  context,
                  listen: false,
                ).loadApplications(studentId);
              }
            },
            icon: const Icon(Icons.add),
            label: const Text("Add Application"),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                RouteManager.editStudentProfile,
              );
              _refresh();
            },
            icon: const Icon(Icons.edit),
            label: const Text("Edit Student Info"),
            backgroundColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildDocStatus(String label, String? value) {
    return ListTile(
      title: Text(label),
      trailing: Icon(
        value != null && value.isNotEmpty ? Icons.check_circle : Icons.cancel,
        color: value != null && value.isNotEmpty ? Colors.green : Colors.red,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
