import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:vishnu_training_and_placements/routes/app_routes.dart';
import 'package:vishnu_training_and_placements/services/token_service.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showText = false;
  late bool isLoggedIn;
  late String role;

  Future<void> _findLogin() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = await TokenService().checkAndRefreshToken();
    role = prefs.getString('role')!;
  }

  @override
  void initState() {
    super.initState();
    _findLogin();
    Timer(const Duration(milliseconds: 1500), () {
      setState(() => _showText = true);

      Future.delayed(const Duration(seconds: 3), () async {
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
