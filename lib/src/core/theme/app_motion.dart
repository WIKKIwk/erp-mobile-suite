import 'package:flutter/animation.dart';

class AppMotion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 380);
  static const Duration pageEnter = Duration(milliseconds: 320);
  static const Duration pageExit = Duration(milliseconds: 260);

  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve smooth = Curves.easeInOutCubicEmphasized;
  static const Curve settle = Curves.easeOutCubic;
  static const Curve pageIn = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve pageOut = Cubic(0.4, 0.0, 1.0, 1.0);
  static const Curve spring = Curves.easeOutBack;
}
