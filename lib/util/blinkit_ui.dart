import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';

/// Presentation-only palette helpers for the Blinkit-style redesign.
class BlinkitUi {
  static const Color ink = Color(0xFF1C1C1C);
  static const Color yellow = Color(0xFFFDD876);
  static const Color yellowDeep = Color(0xFFF8CB46);
  static const Color red = Color(0xFFFF0033);
  static const Color surface = Color(0xFFF3F4FA);
  static const Color gold = Color(0xFFFFB800);

  /// Food module uses the red theme, every other module uses yellow.
  static bool isFood() {
    final SplashController splash = Get.find<SplashController>();
    return splash.module != null && splash.module!.moduleType.toString() == AppConstants.food;
  }

  static Color accent() => isFood() ? red : yellow;

  /// Text/icon color that stays readable on the accent background.
  static Color onAccent() => isFood() ? Colors.white : ink;
}
