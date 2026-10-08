import 'package:flutter/material.dart';

import 'rushd_colors.dart';

abstract final class RushdTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      scaffoldBackgroundColor: RushdColors.lightBackground,

      colorScheme: const ColorScheme.light(
        primary: RushdColors.primary,
        secondary: RushdColors.primaryLight,
        surface: RushdColors.lightSurface,
        onSurface: RushdColors.lightTextPrimary,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: RushdColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        color: RushdColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: RushdColors.lightBorder, width: 1),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: RushdColors.lightBorder,
        thickness: 1,
      ),

      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        indicatorColor: Color(0x1A0F766E),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      scaffoldBackgroundColor: RushdColors.darkBackground,

      colorScheme: const ColorScheme.dark(
        primary: RushdColors.primaryLight,
        secondary: RushdColors.primary,
        surface: RushdColors.darkSurface,
        onSurface: RushdColors.darkTextPrimary,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: RushdColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        color: RushdColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: RushdColors.darkBorder, width: 1),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: RushdColors.darkBorder,
        thickness: 1,
      ),

      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: RushdColors.darkSurface,
        elevation: 0,
        indicatorColor: Color(0x2614B8A6),
      ),
    );
  }
}
