import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin_applications_view_model.dart';
import '../../models/application.dart';

class AdminApplicationsScreen extends StatefulWidget {
  const AdminApplicationsScreen({super.key});

  @override
  State<AdminApplicationsScreen> createState() =>
      _AdminApplicationsScreenState();
}

class _AdminApplicationsScreenState extends State<AdminApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminApplicationsViewModel>(
        context,
        listen: false,
      ).loadAllApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Applications"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<AdminApplicationsViewModel>(
                context,
                listen: false,
              ).loadAllApplications();
            },
          ),
        ],
      ),
      body: Consumer<AdminApplicationsViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Error: ${vm.errorMessage}",
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => vm.loadAllApplications(),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          if (vm.applications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No applications submitted yet.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: vm.applications.length,
            itemBuilder: (context, index) {
              final app = vm.applications[index];
              return _buildApplicationCard(context, app, vm);
            },
          );
        },
      ),
    );
  }

  Widget _buildApplicationCard(
    BuildContext context,
    Application app,
    AdminApplicationsViewModel vm,
  ) {
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

    // Format student ID for display
    final shortStudentId = app.studentId.length > 12
        ? '${app.studentId.substring(0, 8)}...${app.studentId.substring(app.studentId.length - 4)}'
        : app.studentId;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(Icons.description, color: statusColor),
        ),
        title: Text(
          "${app.firstModule.moduleCode} - ${app.firstModule.moduleName.isNotEmpty ? app.firstModule.moduleName : 'Module Name Not Found'}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Student: $shortStudentId"),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Status: ${app.status}",
                style: TextStyle(color: statusColor, fontSize: 12),
              ),
            ),
          ],
        ),
        trailing: Text(
          _formatDate(app.timeOfApplication),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),

                // Application Details
                _buildDetailRow("Application ID", app.applicationId ?? "N/A"),
                _buildDetailRow("Student ID", app.studentId),
                _buildDetailRow(
                  "Time Applied",
                  _formatDateTime(app.timeOfApplication),
                ),
                const SizedBox(height: 12),

                // First Module
                const Text(
                  "First Module",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                _buildDetailRow("Module Code", app.firstModule.moduleCode),
                _buildDetailRow(
                  "Module Name",
                  app.firstModule.moduleName.isNotEmpty
                      ? app.firstModule.moduleName
                      : "Not available in database",
                ),
                _buildDetailRow(
                  "Academic Level",
                  app.firstModule.academicLevel.isNotEmpty
                      ? app.firstModule.academicLevel
                      : "Not available in database",
                ),

                // Second Module (if exists)
                if (app.secondModule != null) ...[
                  const SizedBox(height: 12),
                  const Text(
                    "Second Module",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  _buildDetailRow("Module Code", app.secondModule!.moduleCode),
                  _buildDetailRow(
                    "Module Name",
                    app.secondModule!.moduleName.isNotEmpty
                        ? app.secondModule!.moduleName
                        : "Not available in database",
                  ),
                  _buildDetailRow(
                    "Academic Level",
                    app.secondModule!.academicLevel.isNotEmpty
                        ? app.secondModule!.academicLevel
                        : "Not available in database",
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // Status Update Section
                const Text(
                  "Update Status",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showStatusConfirmationDialog(
                          context,
                          app,
                          vm,
                          "Pending",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Pending"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showStatusConfirmationDialog(
                          context,
                          app,
                          vm,
                          "Approved",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Approve"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showStatusConfirmationDialog(
                          context,
                          app,
                          vm,
                          "Rejected",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Reject"),
                      ),
                    ),
                  ],
                ),

                // Show success/failure feedback
                const SizedBox(height: 8),
                _buildStatusUpdateFeedback(vm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusUpdateFeedback(AdminApplicationsViewModel vm) {
    if (vm.errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          "Error: ${vm.errorMessage}",
          style: const TextStyle(color: Colors.red, fontSize: 12),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _showStatusConfirmationDialog(
    BuildContext context,
    Application app,
    AdminApplicationsViewModel vm,
    String newStatus,
  ) async {
    final action = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${newStatus} Application"),
        content: Text(
          "Are you sure you want to change this application status to $newStatus?\n\n"
          "Module: ${app.firstModule.moduleCode}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == "Approved"
                  ? Colors.green
                  : (newStatus == "Rejected" ? Colors.red : Colors.orange),
            ),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );

    if (action == true) {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Updating status to $newStatus...")),
      );

      await vm.updateApplicationStatus(app.applicationId!, newStatus);

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Application status updated to $newStatus"),
            backgroundColor: newStatus == "Approved"
                ? Colors.green
                : (newStatus == "Rejected" ? Colors.red : Colors.orange),
          ),
        );
      }
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _formatDateTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return "${date.day}/${date.month}/${date.year} $hour:$minute";
  }
}
