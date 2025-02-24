import 'package:flutter/material.dart';

import 'screens/mark_attendance.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MarkAttendancePage());
  }
}
