import 'package:flutter/material.dart';
import 'package:vishnu_training_and_placements/roots/app_roots.dart';
//import 'package:vishnu_training_and_placements/roots/app_roots.dart';
import 'package:vishnu_training_and_placements/screens/AdminAttendanceScreen.dart';
import 'package:vishnu_training_and_placements/screens/Splash_Screen.dart';
import 'package:flutter/foundation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
      onGenerateRoute: (settings) {
        // If the requested route is not found, redirect to splash screen
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        );
      },
    );
  }
}
