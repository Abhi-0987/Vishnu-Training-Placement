import 'package:flutter/material.dart';
import 'dart:ui';

class BlurredCard extends StatelessWidget {
  final Widget child;
  
  const BlurredCard({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return ClipRRect(
      borderRadius: BorderRadius.circular(screenWidth * 0.05),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.03),
          decoration: BoxDecoration(
            color: Color.alphaBlend(Colors.white.withAlpha(77), Colors.transparent),
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
          ),
          child: child,
        ),
      ),
    );
  }
}
