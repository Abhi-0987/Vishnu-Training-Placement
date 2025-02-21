import 'package:flutter/material.dart';
import 'dart:ui';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Background(),
  ));
}

class Background extends StatelessWidget {
  const Background({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: -screenSize.height * 0.02,
            right: -screenSize.width * 0.1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(150),
              child: Container(
                width: screenSize.width * 0.6,
                height: screenSize.width * 0.6,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(205, 31, 176, 1),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -screenSize.height * 0.05,
            left: -screenSize.width * 0.1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(150),
              child: Container(
                width: screenSize.width * 0.6,
                height: screenSize.width * 0.6,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 65, 180, 161),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: Container(
                color: Color.alphaBlend(
                  Colors.black.withAlpha(153), // Approximate opacity of 0.6
                  Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
