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
  static const Color blue = Color(0xFFB3D7FA);
  static const Color cyan = Color(0xFFB2F0F7);
  static const Color teal = Color(0xFF2CC5D2);
  static const Color aqua = Color(0xFF86FBEF);
  static const Color surface = Color(0xFFF3F4FA);
  static const Color gold = Color(0xFFFFB800);

  static String? _moduleType() {
    final SplashController splash = Get.find<SplashController>();
    return splash.module?.moduleType?.toString();
  }

  static String _moduleName() {
    final SplashController splash = Get.find<SplashController>();
    return (splash.module?.moduleName ?? '').toLowerCase();
  }

  /// Food module uses the red theme.
  static bool isFood() => _moduleType() == AppConstants.food;

  /// Every module has its own header / nav accent (see reference video):
  /// grocery yellow, food red, fashion light blue, parcel light cyan,
  /// medicine teal, rental / others aqua.
  static Color accent() {
    final String? type = _moduleType();
    if (type == null) return yellow;
    if (_moduleName().contains('meat')) return aqua;
    if (type == AppConstants.food) return red;
    if (type == AppConstants.grocery) return yellow;
    if (type == AppConstants.ecommerce) return blue;
    if (type == AppConstants.parcel) return cyan;
    if (type == AppConstants.pharmacy) return teal;
    return aqua;
  }

  /// Text/icon color that stays readable on the accent background.
  static Color onAccent() => isFood() ? Colors.white : ink;

  /// Soft tinted colors used behind section headers / carousels.
  static List<Color> sectionTint() {
    final Color a = accent();
    if (a == red) return const [Color(0xFFF8A5BD), Color(0xFFFDE6EC)];
    if (a == yellow) return const [Color(0xFFFFF1BF), Color(0xFFFFFBEB)];
    if (a == blue) return const [Color(0xFFD3E8FC), Color(0xFFF2F8FE)];
    if (a == cyan) return const [Color(0xFFD5F6FA), Color(0xFFF3FCFD)];
    if (a == teal) return const [Color(0xFFA8E6EC), Color(0xFFEAF9FB)];
    return const [Color(0xFFC9FBF5), Color(0xFFF2FEFC)];
  }
}
