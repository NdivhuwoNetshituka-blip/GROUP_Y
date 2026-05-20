import 'package:flutter/material.dart';
import 'package:student_assistant_application_system/views/auth/sign_up.dart';
import '../views/auth/splash_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/student/home_screen.dart';
import '../views/student/application_form_screen.dart';
import '../views/student/application_detail_screen.dart';
import '../views/admin/admin_dashboard_screen.dart';
import '../views/admin/admin_applications_screen.dart';
import '../views/student/edit_student_profile.dart';
import '../views/admin/admin_students_screen.dart';

class RouteManager {
  static const String splashScreen = '/';
  static const String logInScreen = '/login';
  static const String signUpScreen = '/signup';
  static const String homeScreen = '/home';
  static const String applicationFormScreen = '/application_form';
  static const String applicationDetailScreen = '/application_detail';
  static const String adminDashBoard = '/admin_dashboard';
  static const String editStudentProfile = '/edit_profile';
  static const String adminApplicationsScreen =
      '/admin_applications';
  static const String adminStudentsScreen = '/admin_students';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreen:
        return MaterialPageRoute(builder: (context) => SplashScreen());
      case signUpScreen:
        return MaterialPageRoute(builder: (context) => SignUpScreen());
      case logInScreen:
        return MaterialPageRoute(builder: (context) => LoginScreen());
      case homeScreen:
        return MaterialPageRoute(builder: (context) => HomeScreen());
      case adminStudentsScreen:
        return MaterialPageRoute(
          builder: (context) => const AdminStudentsScreen(),
        );
      case applicationFormScreen:
        return MaterialPageRoute(builder: (context) => ApplicationFormScreen());
      case applicationDetailScreen:
        return MaterialPageRoute(
          builder: (context) => ApplicationDetailScreen(),
        );
      case adminDashBoard:
        return MaterialPageRoute(builder: (context) => AdminDashboardScreen());
      case editStudentProfile:
        return MaterialPageRoute(builder: (context) => EditStudentProfile());
      case adminApplicationsScreen: 
        return MaterialPageRoute(
          builder: (context) => const AdminApplicationsScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }
}
