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
 * File: admin_dashboard_screen.dart
 * Description: Admin dashboard - review, approve, reject, and delete applications.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/application.dart';
import '../../routes/route_manager.dart';
import '../../viewmodels/application_view_model.dart';
import '../../viewmodels/auth_view_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Provider.of<ApplicationViewModel>(
        context,
        listen: false,
      ).loadAllApplications(),
    );
  }

  Future<void> _logout() async {
    await Provider.of<AuthViewModel>(context, listen: false).signOut();
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

  Future<void> _decide(Application app, String newStatus) async {
    final vm = Provider.of<ApplicationViewModel>(context, listen: false);
    final success = await vm.changeStatus(app.applicationId!, newStatus);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Application $newStatus.' : 'Could not update status.',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Application app) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove application?'),
        content: const Text('This permanently removes the application record.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final vm = Provider.of<ApplicationViewModel>(context, listen: false);
    await vm.deleteApplication(app.applicationId!);
  }

  void _showApplicationDetail(Application app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, scroll) => SingleChildScrollView(
            controller: scroll,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Text(
                    'Application Review',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    title: const Text('Student ID'),
                    subtitle: Text(app.studentId),
                  ),
                ),
                Card(
                  child: ListTile(
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
                    title: const Text('First module'),
                    subtitle: Text(app.firstModule.moduleCode),
                  ),
                ),
                if (app.secondModule != null)
                  Card(
                    child: ListTile(
                      title: const Text('Second module'),
                      subtitle: Text(app.secondModule!.moduleCode),
                    ),
                  ),
                Card(
                  child: ListTile(
                    title: const Text('Eligibility confirmed'),
                    subtitle: Text(app.confirmedEligibility ? 'Yes' : 'No'),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text('Submitted on'),
                    subtitle: Text(
                      '${app.timeOfApplication.day}/${app.timeOfApplication.month}/${app.timeOfApplication.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (app.status.toLowerCase() == 'pending') ...[
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text(
                        'Approve',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _decide(app, 'Approved');
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _decide(app, 'Rejected');
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                SizedBox(
                  height: 50,
                  child: TextButton.icon(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text(
                      'Delete application',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _confirmDelete(app);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (v) => setState(() => _filter = v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'All', child: Text('All')),
              PopupMenuItem(value: 'Pending', child: Text('Pending')),
              PopupMenuItem(value: 'Approved', child: Text('Approved')),
              PopupMenuItem(value: 'Rejected', child: Text('Rejected')),
            ],
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Consumer<ApplicationViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filtered = _filter == 'All'
              ? vm.applications
              : vm.applications
                    .where(
                      (a) => a.status.toLowerCase() == _filter.toLowerCase(),
                    )
                    .toList();

          if (filtered.isEmpty) {
            return RefreshIndicator(
              onRefresh: vm.loadAllApplications,
              child: ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('No applications to display.')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: vm.loadAllApplications,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final app = filtered[i];
                return Card(
                  child: ListTile(
                    title: Text('Student: ${app.studentId.substring(0, 8)}...'),
                    subtitle: Text(
                      '${app.firstModule.moduleCode}'
                      '${app.secondModule != null ? ' + ${app.secondModule!.moduleCode}' : ''}\n'
                      'Submitted ${app.timeOfApplication.day}/${app.timeOfApplication.month}/${app.timeOfApplication.year}',
                    ),
                    isThreeLine: true,
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
                    onTap: () => _showApplicationDetail(app),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
