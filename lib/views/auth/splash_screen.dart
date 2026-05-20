import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../routes/route_manager.dart';
import '../../viewmodels/auth_view_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _checkUser();
  }

  Future<void> _checkUser() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    await Future.delayed(const Duration(seconds: 2));

    try {
      final currentUser = await authViewModel.getCurrentUser();

      if (!mounted) return;

      /// USER EXISTS
      if (currentUser != null) {
        /// ADMIN
        if (currentUser.role == "admin") {
          Navigator.pushReplacementNamed(context, RouteManager.adminDashBoard);
        } else {
          /// STUDENT
          Navigator.pushReplacementNamed(context, RouteManager.homeScreen);
        }
      } else {
        /// NO USER
        Navigator.pushReplacementNamed(context, RouteManager.logInScreen);
      }
    } catch (e) {
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, RouteManager.logInScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purple],

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(Icons.school, color: Colors.white, size: 100),

            SizedBox(height: 20),

            Text(
              "Student Assistant",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            Text(
              "Application System",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),

            SizedBox(height: 40),

            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
