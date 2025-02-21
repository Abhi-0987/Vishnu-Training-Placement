import 'package:flutter/material.dart';
import 'package:vishnu_training_and_placements/event_venue.dart';
import 'package:vishnu_training_and_placements/student_profile.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: EventVenue(),
    );
  }
}
