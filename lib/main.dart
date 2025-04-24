import 'package:flutter/material.dart';
import 'package:vishnu_training_and_placements/routes/app_routes.dart';
// import 'package:vishnu_training_and_placements/screens/AdminAttendanceScreen.dart';
// import 'package:vishnu_training_and_placements/screens/student_schedule_screen.dart';

void main() {
  runApp(const MaterialApp(home: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
      // home: StudentLoginScreen(isAdmin: false),
      //home: StudentSchedulesScreen(),
    );
  }
}
