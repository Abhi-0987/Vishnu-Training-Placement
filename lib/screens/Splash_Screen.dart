// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:vishnu_training_and_placements/routes/app_routes.dart';
import 'package:vishnu_training_and_placements/services/token_service.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';

//splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const platform = MethodChannel('dev_options_channel');
  bool _showText = false;
  late bool isLoggedIn;
  late String role;

  Future<void> _findLogin() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = await TokenService().checkAndRefreshToken();
    role = prefs.getString('role') ?? " ";
  }

  @override
  void initState() {
    super.initState();
    _startAppFlow();
  }
  Future<void> _startAppFlow() async {
    Timer(const Duration(milliseconds: 1500), () {
      setState(() => _showText = true);

      Future.delayed(const Duration(seconds: 3), () async {
        if (!mounted) return;
        bool shouldProceed = await _checkDevOptions();
        if (!shouldProceed) return;
        await _findLogin();
        if (!mounted) return;
          if (isLoggedIn) {
            if (role == 'student') {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.studentHomeScreen,
              );
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.adminHomeScreen);
            }
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.welcome);
          }
      });
    });
  }
  Future<bool> _checkDevOptions() async {
    try {
      final bool isDevOptionsEnabled =
          await platform.invokeMethod("isDevOptionsEnabled");

      if (isDevOptionsEnabled) {
        _showBlockDialog();
        return false;
      }
      return true;
    } on PlatformException catch (e) {
      debugPrint("Failed to get Developer Options: '${e.message}'.");
      // Proceed anyway if error
      return true;
    }
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Developer Options Enabled"),
        content: const Text(
            "Please disable Developer Options to continue using this app."),
        actions: [
          TextButton(
            onPressed: () => SystemNavigator.pop(), // Exit app
            child: const Text("Exit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 1, 22, 23),
              Color.fromARGB(255, 26, 26, 26),
              Color.fromARGB(255, 2, 43, 36),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1500),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: 1,
                    child: Transform.rotate(
                      angle: value * 6.28,
                      child: Transform.scale(scale: value * 2, child: child),
                    ),
                  );
                },
                child: Image.asset('assets/logo.png', width: 100),
              ),
              const SizedBox(height: 40),
              AnimatedOpacity(
                opacity: _showText ? 1 : 0,
                duration: const Duration(seconds: 2),
                child: const Text(
                  'Vishnu Training and Placements',
                  style: TextStyle(
                    color: AppConstants.textWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
