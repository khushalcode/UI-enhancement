import 'package:flutter/material.dart';
import 'package:sixam_mart/util/app_constants.dart';

ThemeData light({Color color = const Color(0xFFFC3202)}) => ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: color,
  secondaryHeaderColor: const Color(0xFFFC3202),
  disabledColor: const Color(0xFF9F9F9F),
  brightness: Brightness.light,
  hintColor: const Color(0xFF9F9F9F),
  cardColor: Colors.white,
  scaffoldBackgroundColor: const Color(0xFFF8F7F5),
  shadowColor: Colors.black.withValues(alpha: 0.03),
  splashFactory: InkRipple.splashFactory,
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: color)),
  colorScheme: ColorScheme.light(primary: color, secondary: color).copyWith(
      surface: const Color(0xFFF8F7F5)).copyWith(error: const Color(0xFFE84D4F)),
  appBarTheme: const AppBarTheme(
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: Colors.white, surfaceTintColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),
  dialogTheme: DialogThemeData(
    surfaceTintColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    surfaceTintColor: Colors.white,
    showDragHandle: false,
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(color: color),
  floatingActionButtonTheme: FloatingActionButtonThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500))),
  bottomAppBarTheme: const BottomAppBarThemeData(
    surfaceTintColor: Colors.white, height: 60,
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
  dividerTheme: const DividerThemeData(thickness: 0.5, color: Color(0xFFE6E3DF)),
  tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
);
