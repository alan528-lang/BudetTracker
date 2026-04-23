import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg       = Color(0xFF060B18);
  static const bg2      = Color(0xFF0D1425);
  static const bg3      = Color(0xFF131D32);
  static const card     = Color(0xFF0F1A2E);
  static const card2    = Color(0xFF16243D);
  static const accent   = Color(0xFF10E8A0);
  static const accent2  = Color(0xFF0CC880);
  static const accentBg = Color(0x1A10E8A0);
  static const red      = Color(0xFFFF4D6D);
  static const redBg    = Color(0x1AFF4D6D);
  static const blue     = Color(0xFF4DA6FF);
  static const gold     = Color(0xFFF4C56A);
  static const purple   = Color(0xFFA78BFA);
  static const text     = Color(0xFFEEF2FF);
  static const text2    = Color(0xFF6B7FA3);
  static const text3    = Color(0xFF334155);
  static const border   = Color(0x0FFFFFFF);
  static const border2  = Color(0x1FFFFFFF);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.blue,
      surface: AppColors.card,
      error: AppColors.red,
    ),
    textTheme: GoogleFonts.cairoTextTheme(
      const TextTheme(
        displayLarge:  TextStyle(color: AppColors.text, fontWeight: FontWeight.w900),
        displayMedium: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700),
        headlineLarge: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700),
        headlineMedium:TextStyle(color: AppColors.text, fontWeight: FontWeight.w700),
        titleLarge:    TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
        titleMedium:   TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
        bodyLarge:     TextStyle(color: AppColors.text),
        bodyMedium:    TextStyle(color: AppColors.text2),
        labelLarge:    TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
        labelMedium:   TextStyle(color: AppColors.text2, fontSize: 12),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: AppColors.text),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.red),
      ),
      hintStyle: const TextStyle(color: AppColors.text3),
      labelStyle: const TextStyle(color: AppColors.text2),
      prefixIconColor: AppColors.text3,
      suffixIconColor: AppColors.text3,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.bg,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xF0090E1C),
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.text3,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    ),
    dividerColor: AppColors.border,
    cardColor: AppColors.card,
  );
}
