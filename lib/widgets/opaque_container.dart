import 'package:flutter/material.dart';

class OpaqueContainer extends Container {
  OpaqueContainer({
    super.key,
    required Widget super.child,
    required double super.width,
  }) : super(
         padding: EdgeInsets.all(width * 0.05),
         decoration: BoxDecoration(
           color: const Color.fromRGBO(255, 255, 255, 0.1),
           borderRadius: BorderRadius.circular(width * 0.04),
           border: Border.all(
             color: const Color.fromRGBO(255, 255, 255, 0.1),
             width: 1,
           ),
         ),
       );
}
