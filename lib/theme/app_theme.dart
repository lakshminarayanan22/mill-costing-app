import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1A56DB);
  static const Color primaryLight = Color(0xFFEBF0FF);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF111928);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color success = Color(0xFF057A55);
  static const Color successLight = Color(0xFFDEF7EC);
  static const Color danger = Color(0xFFE02424);
  static const Color dangerLight = Color(0xFFFDE8E8);
  static const Color warning = Color(0xFFE3A008);
  static const Color warningLight = Color(0xFFFDF6B2);
  static const Color divider = Color(0xFFE5E7EB);

  // Cost component colours (for donut chart)
  static const List<Color> componentColors = [
    Color(0xFF1A56DB), // Material — blue
    Color(0xFFE3A008), // Power — amber
    Color(0xFF057A55), // Interest — green
    Color(0xFF9061F9), // Depreciation — purple
    Color(0xFFFF5A1F), // Labour — orange
    Color(0xFF0E9F6E), // Overhead — teal
    Color(0xFFE02424), // Packing — red
    Color(0xFF6B7280), // Yarn Waste — grey
    Color(0xFF1C64F2), // TFO Conv. — indigo
  ];

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: surface,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardThemeData(
          color: card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: divider),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          labelStyle: const TextStyle(color: textSecondary, fontSize: 13),
          isDense: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textPrimary),
          titleMedium: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textPrimary),
          titleSmall: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textPrimary),
          bodyMedium: TextStyle(fontSize: 14, color: textPrimary),
          bodySmall: TextStyle(fontSize: 12, color: textSecondary),
          labelSmall: TextStyle(fontSize: 11, color: textSecondary),
        ),
      );
}
