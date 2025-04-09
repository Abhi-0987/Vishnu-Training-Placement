import 'package:flutter/material.dart';
import 'package:vishnu_training_and_placements/roots/app_roots.dart';
import 'package:vishnu_training_and_placements/screens/event_venue.dart';

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
    );
  }
}
