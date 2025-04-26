import 'package:flutter/material.dart';
import 'package:vishnu_training_and_placements/routes/app_routes.dart';
import 'package:vishnu_training_and_placements/screens/AdminAttendanceScreen.dart';
import 'package:vishnu_training_and_placements/screens/admin_homescreen.dart';
import 'package:vishnu_training_and_placements/screens/admin_profile_screen.dart';
import 'package:vishnu_training_and_placements/screens/event_venue.dart';
import 'package:vishnu_training_and_placements/screens/login_screen.dart';
import 'package:vishnu_training_and_placements/screens/mark_attendance.dart';
import 'package:vishnu_training_and_placements/screens/splash_screen.dart';
import 'package:vishnu_training_and_placements/screens/student_change_password_screen.dart';
import 'package:vishnu_training_and_placements/screens/student_homescreen.dart';
import 'package:vishnu_training_and_placements/screens/student_profile.dart';
import 'package:vishnu_training_and_placements/screens/student_schedule_screen.dart';
// import 'package:vishnu_training_and_placements/screens/welcome_screen.dart';

void main() {
  runApp(const MaterialApp(home: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowCheckedModeBanner: false,
      // initialRoute: AppRoutes.welcome,
      // routes: AppRoutes.routes,
      // home: MarkAttendancePage(),
      home: StudentProfileScreen(),
    );
  }
}
