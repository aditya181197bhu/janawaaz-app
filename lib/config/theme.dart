import 'package:flutter/material.dart';

class JaColors {
  static const Color navy = Color(0xFF14215A);
  static const Color primary = Color(0xFF1F3B8C);
  static const Color primaryLight = Color(0xFF3D63C9);
  static const Color sky = Color(0xFFE8EEFB);
  static const Color saffron = Color(0xFFD9772B);
  static const Color background = Color(0xFFF4F6FB);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1A2138);
  static const Color textSecondary = Color(0xFF5C6680);
  static const Color divider = Color(0xFFDDE3EF);
  static const Color error = Color(0xFFC62828);

  // Survey and status colours: muted so they stay readable in sunlight.
  static const Color green = Color(0xFF2E8B57);
  static const Color yellow = Color(0xFFE0A21B);
  static const Color red = Color(0xFFC8372D);
  static const Color grey = Color(0xFF9AA3B5);
}

class JaTheme {
  static ThemeData get light {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: JaColors.primary,
        primary: JaColors.primary,
        secondary: JaColors.saffron,
        surface: JaColors.surface,
        error: JaColors.error,
      ),
      scaffoldBackgroundColor: JaColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: JaColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: JaColors.sky,
        labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: JaColors.textPrimary)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: JaColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: shape,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: JaColors.primary,
          minimumSize: const Size(double.infinity, 52),
          shape: shape,
          side: const BorderSide(color: JaColors.primary, width: 1.4),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: JaColors.divider)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: JaColors.divider)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: JaColors.primary, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: JaColors.divider),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: JaColors.divider),
      ),
    );
  }
}
