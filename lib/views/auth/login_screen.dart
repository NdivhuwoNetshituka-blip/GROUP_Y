import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_view_model.dart';
import '../admin/admin_dashboard_screen.dart';
import '../student/home_screen.dart';
import '../../routes/route_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                const Text(
                  "Student Assistant System",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 40),

                /// EMAIL
                TextField(
                  controller: _emailController,

                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                /// PASSWORD
                TextField(
                  controller: _passwordController,
                  obscureText: true,

                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                /// ERROR
                if (authViewModel.errorMessage != null)
                  Text(
                    authViewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),

                const SizedBox(height: 20),

                /// LOGIN BUTTON
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: authViewModel.isLoading
                        ? null
                        : () async {
                            await authViewModel.signIn(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );

                            if (!mounted) return;

                            if (authViewModel.currentUser != null) {
                              final role = authViewModel.currentUser!.role;

                              /// ADMIN
                              if (role == "admin") {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AdminDashboardScreen(),
                                  ),
                                );
                              } else {
                                /// STUDENT
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HomeScreen(),
                                  ),
                                );
                              }
                            }
                          },

                    child: authViewModel.isLoading
                        ? const CircularProgressIndicator()
                        : const Text("Login"),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RouteManager.signUpScreen);
                  },
                  child: const Text("Don't have an account? Sign up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
