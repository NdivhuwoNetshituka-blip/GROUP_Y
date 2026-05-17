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
 * File: application_detail_screen.dart
 * Description: Shows full details of an application and lets the student edit or delete it.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../routes/route_manager.dart';
import '../../viewmodels/application_view_model.dart';

class ApplicationDetailScreen extends StatelessWidget {
  const ApplicationDetailScreen({super.key});

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

  Future<void> _confirmDelete(BuildContext context) async {
    final vm = Provider.of<ApplicationViewModel>(context, listen: false);
    final appId = vm.applicationId;
    if (appId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete application?'),
        content: const Text(
          'This action cannot be undone. Your application will be permanently removed.',
        ),
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

    if (confirm != true) return;
    final success = await vm.deleteApplication(appId);
    if (!context.mounted) return;
    if (success) {
      vm.resetForm();
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Application deleted.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage ?? 'Could not delete.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application details'),
        actions: [
          Consumer<ApplicationViewModel>(
            builder: (context, vm, _) {
              final isPending = vm.status.toLowerCase() == 'pending';
              if (!isPending) return const SizedBox.shrink();
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => Navigator.pushNamed(
                      context,
                      RouteManager.applicationFormScreen,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<ApplicationViewModel>(
        builder: (context, vm, _) {
          if (vm.applicationId == null) {
            return const Center(child: Text('No application loaded.'));
          }
          final isPending = vm.status.toLowerCase() == 'pending';
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  title: const Text('Status'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(vm.status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _statusColor(vm.status)),
                    ),
                    child: Text(
                      vm.status,
                      style: TextStyle(
                        color: _statusColor(vm.status),
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
                  subtitle: Text(vm.firstModule.moduleCode),
                ),
              ),
              if (vm.secondModule != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.book_outlined),
                    title: const Text('Second module'),
                    subtitle: Text(vm.secondModule!.moduleCode),
                  ),
                ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: const Text('Eligibility confirmed'),
                  subtitle: Text(vm.confirmedEligibility ? 'Yes' : 'No'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Submitted on'),
                  subtitle: Text(
                    '${vm.timeOfApplication.day}/${vm.timeOfApplication.month}/${vm.timeOfApplication.year}',
                  ),
                ),
              ),
              if (!isPending) ...[
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'This application has been reviewed and cannot be edited.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
