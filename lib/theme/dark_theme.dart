import 'package:flutter/material.dart';
import 'package:sixam_mart/util/app_constants.dart';

ThemeData dark({Color color = const Color(0xFFFC3202)}) => ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: color,
  secondaryHeaderColor: const Color(0xfffc3202),
  disabledColor: const Color(0xffa2a7ad),
  brightness: Brightness.dark,
  hintColor: const Color(0xFFbebebe),
  cardColor: const Color(0xFF262833),
  scaffoldBackgroundColor: const Color(0xFF14151E),
  shadowColor: Colors.white.withValues(alpha: 0.03),
  splashFactory: InkRipple.splashFactory,
  textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white70)),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: color)),
  colorScheme: ColorScheme.dark(primary: color, secondary: color).copyWith(surface: const Color(0xFF14151E)).copyWith(error: const Color(0xFFdd3135)),
  appBarTheme: const AppBarTheme(
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: const Color(0xFF29292D), surfaceTintColor: const Color(0xFF29292D),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),
  dialogTheme: DialogThemeData(
    surfaceTintColor: Colors.white10,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    surfaceTintColor: Colors.transparent,
    showDragHandle: false,
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(color: color),
  floatingActionButtonTheme: FloatingActionButtonThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500))),
  bottomAppBarTheme: const BottomAppBarThemeData(
    surfaceTintColor: Colors.black, height: 60,
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
  dividerTheme: const DividerThemeData(thickness: 0.5, color: Color(0xFF3A3C4A)),
  tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
);
