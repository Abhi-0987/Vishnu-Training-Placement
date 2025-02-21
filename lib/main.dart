import 'package:flutter/material.dart';
import 'package:vishnu_training_and_placements/screens/mark_attendance.dart';
import 'screens/mark_attendence_admin.dart';

void main() {
  runApp(const MaterialApp(home: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MarkAttendancePage(),
    );
  }
}
