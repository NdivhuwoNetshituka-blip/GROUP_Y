import 'package:flutter/material.dart';
import '../views/auth/splash_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/student/home_screen.dart';
import '../views/student/application_form_screen.dart';
import '../views/student/application_detail_screen.dart';
import '../views/admin/admin_dashboard_screen.dart';

class RouteManager {
  static const String splashScreen = '/';
  static const String logInScreen = '/login';
  static const String homeScreen = '/home';
  static const String applicationFormScreen = '/application_form';
  static const String applicationDetailScreen = '/application_detail';
  static const String adminDashBoard = '/admin_dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreen:
        return MaterialPageRoute(builder: (context) => SplashScreen());
      case logInScreen:
        return MaterialPageRoute(builder: (context) => LoginScreen());
      case homeScreen:
        return MaterialPageRoute(builder: (context) => StudentHomeScreen());
      case applicationFormScreen:
        return MaterialPageRoute(builder: (context) => ApplicationFormScreen());
      case applicationDetailScreen:
        return MaterialPageRoute(
          builder: (context) => ApplicationDetailScreen(),
        );
      case adminDashBoard:
        return MaterialPageRoute(builder: (context) => AdminDashboardScreen());
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }
}
