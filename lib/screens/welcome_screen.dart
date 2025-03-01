import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vishnu_training_and_placements/roots/app_roots.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double height = screenSize.height;
    final double width = screenSize.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: height * 0.08,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vishnu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.09,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Alata',
                  ),
                ),
                SizedBox(width: width * 0.02),
                Column(
                  children: [
                    Text(
                      'Training and',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.05,
                        fontFamily: 'Alata',
                      ),
                    ),
                    Text(
                      'Placements',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.05,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
              ),
            ),
          ),

          // Decorative Circles
          Positioned(
            top: -height * 0.15,
            left: -width * 0.35,
            child: Container(
              width: width * 0.7,
              height: height * 0.35,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(102, 16, 88, 0.2),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(102, 16, 88, 0.5),
                    blurRadius: 150,
                    spreadRadius: 80,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: -height * 0.15,
            right: -width * 0.35,
            child: Container(
              width: width * 0.7,
              height: height * 0.35,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(43, 139, 123, 0.01),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(61, 82, 34, 0.8),
                    blurRadius: 150,
                    spreadRadius: 100,
                  ),
                ],
              ),
            ),
          ),

          // Glass Layer
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: const Color.fromRGBO(255, 255, 255, 0.05),
              ),
            ),
          ),

          Column(
            children: [
              SizedBox(height: height * 0.3),

              Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: width * 0.8,
                      child: Image.asset('assets/tlogo.png'),
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(height: height * 0.03),
                      Align(
                        alignment: Alignment.center,
                        child: ClipRRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              height: height * 0.32,
                              width: width * 0.96,
                              padding: EdgeInsets.all(width * 0.05),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(255, 255, 255, 0.1),
                                borderRadius: BorderRadius.circular(
                                  width * 0.04,
                                ),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Admin Button
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.pinkAccent,
                                          Colors.orangeAccent,
                                        ],
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(3),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 50,
                                          vertical: 12,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.adminLogin,
                                        );
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Admin',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontFamily: 'Alata',
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          Image.asset(
                                            'assets/admin.png',
                                            height: 30,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Student Button
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.pinkAccent,
                                          Colors.orangeAccent,
                                        ],
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(3),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 50,
                                          vertical: 12,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.studentLogin,
                                        );
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'Student',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontFamily: 'Alata',
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          Image.asset(
                                            'assets/student.png',
                                            height: 30,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}