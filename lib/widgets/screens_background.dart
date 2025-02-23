import 'dart:ui';
import 'package:flutter/material.dart';

class ScreensBackground extends StatelessWidget {
  const ScreensBackground({
    super.key,
    required this.height,
    required this.width,
  });
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Stack(
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

        // Top-right decorative circle
        Positioned(
          top: -height * 0.12,
          right: -width * 0.32,
          child: Container(
            width: width * 0.6,
            height: height * 0.3,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromRGBO(102, 16, 88, 0.1),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(102, 16, 88, 0.4),
                  blurRadius: 130,
                  spreadRadius: 70,
                ),
              ],
            ),
          ),
        ),

        // Bottom-left decorative circle
        Positioned(
          bottom: -height * 0.12,
          left: -width * 0.32,
          child: Container(
            width: width * 0.6,
            height: height * 0.3,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromRGBO(43, 139, 123, 0.01),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(43, 139, 123, 0.3),
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
            child: Container(color: const Color.fromRGBO(255, 255, 255, 0.05)),
          ),
        ),
      ],
    );
  }
}
