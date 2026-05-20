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

import '../../routes/route_manager.dart';
import '../../viewmodels/auth_view_model.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    final currentUser = authViewModel.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authViewModel.signOut();

              if (!context.mounted) return;

              Navigator.pushReplacementNamed(context, RouteManager.logInScreen);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// WELCOME
            Text(
              "Welcome Admin",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              currentUser?.email ?? "",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            /// DASHBOARD CARDS (Only Applications & Students)
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _dashboardCard(
                    context,
                    title: "Applications",
                    icon: Icons.description,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RouteManager.adminApplicationsScreen,
                      );
                    },
                  ),
                  _dashboardCard(
                    context,
                    title: "Students",
                    icon: Icons.people,
                    color: Colors.green,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RouteManager.adminStudentsScreen,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
