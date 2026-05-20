import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_assistant_application_system/viewmodels/applications_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_assistant_application_system/viewmodels/admin_applications_view_model.dart';
import 'package:student_assistant_application_system/viewmodels/admin_students_view_model.dart';

import 'routes/route_manager.dart';
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/application_view_model.dart';
import 'viewmodels/student_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fiagwudpgtrlhdlaiize.supabase.co',
    anonKey: 'sb_publishable_pPU8ZWDPMNM0UWOiLb1fSg_P8ZiE-pD',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ApplicationViewModel()),
        ChangeNotifierProvider(create: (_) => StudentViewModel()),
        ChangeNotifierProvider(create: (_) => ApplicationsViewModel()),
        ChangeNotifierProvider(create: (_) => AdminApplicationsViewModel()),
        ChangeNotifierProvider(create: (_) => AdminStudentsViewModel()),
      ],
      child: MaterialApp(
        title: 'Student Assistant Application System',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        onGenerateRoute: RouteManager.generateRoute,
        initialRoute: RouteManager.splashScreen,
      ),
    );
  }
}