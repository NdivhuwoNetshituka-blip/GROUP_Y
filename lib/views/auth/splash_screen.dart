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
 * File: splash_screen.dart
 * Description: Initial splash screen - checks if user is logged in and routes accordingly.
 */

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../routes/route_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decideRoute());
  }

  Future<void> _decideRoute() async {
    // Short delay so the splash is visible to the user
    await Future.delayed(const Duration(milliseconds: 800));

    // Always clear any cached session so the login screen is shown on launch.
    // Supabase persists sessions to local storage by default, which would
    // otherwise send the user straight past the login screen.
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {
      // Safe to ignore - there may not be an active session.
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, RouteManager.logInScreen);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 100, color: Colors.deepPurple),
            SizedBox(height: 20),
            Text(
              'Student Assistant\nApplication System',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
