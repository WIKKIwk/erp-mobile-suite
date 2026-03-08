import 'package:flutter/animation.dart';

class AppMotion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 380);

  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve smooth = Curves.easeInOutCubicEmphasized;
  static const Curve settle = Curves.easeOutQuart;
  static const Curve spring = Curves.easeOutBack;
}
