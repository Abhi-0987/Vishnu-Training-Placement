import 'package:flutter/material.dart';
import 'package:vishnu_training_and_placements/screens/AdminAttendanceScreen.dart';
import 'package:vishnu_training_and_placements/screens/all_schedules_screen.dart';
import 'package:vishnu_training_and_placements/screens/event_venue.dart';
import 'package:vishnu_training_and_placements/screens/schedule_details_screen.dart';
import 'package:vishnu_training_and_placements/screens/student_schedule_screen.dart';

void main() {
  runApp(const MaterialApp(home: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // initialRoute: AppRoutes.splash,
      // routes: AppRoutes.routes,
      // initialRoute: AppRoutes.splash,
      // routes: AppRoutes.routes,
      // home: StudentLoginScreen(isAdmin: false),
      home: StudentSchedulesScreen (),
    );
  }
}
