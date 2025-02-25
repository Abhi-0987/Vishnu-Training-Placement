import 'package:flutter/material.dart';
//import 'package:vishnu_training_and_placements/screens/student_profile.dart';
//import 'package:vishnu_training_and_placements/screens/mark_attendance.dart';
//import 'screens/AdminAttendanceScreen.dart';
import 'screens/student_homescreen.dart';

void main() {
  runApp(const MaterialApp(home: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StudentHomeScreen(),
    );
  }
}
