import 'package:flutter/material.dart';

class AppTheme {
  // Light theme
  static const Color bgLight = Colors.white;
  static const Color bgLightSurface = Color(0xFFF8F9FA);
  static const Color textLightPrimary = Color(0xFF1E1E2C);
  static const Color textLightMuted = Color(0xFF8A8A9E);
  static const Color orangeAccent = Color(0xFFFF5722);
  static const Color blueAccent = Color(0xFF2979FF);

  // ─── Missing Colors (Added to Fix Errors) ──────────────────────────

  static const Color primaryPurple = Color(0xFF6C5CE7);
  static const Color primaryBlue = Color(0xFF4A7CFF);
  static const Color accentTeal = Color(0xFF00BFA6);
  static const Color accentOrange = Color(0xFFFF5722);
  static const Color accentPink = Color(0xFFFF4B8D);
  static const Color textLightSecondary = Color(0xFF8A8A9E);
  static const Color navInactive = Color(0xFF9E9E9E);

  // ─── Dark Theme Colors ─────────────────────────────────────────────
  static const Color bgDark = Color(0xFF0D0D1A);
  static const Color bgCard = Color(0xFF16162A);
  static const Color bgSurface = Color(0xFF1E1E38);
  static const Color bgCardLight = Color(0xFF212140);

  // ─── Neon Accents ──────────────────────────────────────────────────
  static const Color neonPurple = Color(0xFF7B2FBE);
  static const Color neonBlue = Color(0xFF4A90E2);
  static const Color neonPink = Color(0xFFE91E8C);
  static const Color neonYellow = Color(0xFFFFC107);
  static const Color neonGreen = Color(0xFF00E676);
  static const Color neonRed = Color(0xFFFF5252);
  static const Color neonCyan = Color(0xFF00BCD4);

  // ─── Gradients ─────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFF4A7CFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [Color(0xFFFF4B8D), Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient yellowGradient = LinearGradient(
    colors: [Color(0xFFFFC547), Color(0xFFFF9F43)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF00BFA6), Color(0xFF00E5A0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFF4A7CFF), Color(0xFF00BFA6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0D0D1A), Color(0xFF16162A), Color(0xFF1E1E38)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Special Colors ────────────────────────────────────────────────
  static const Color successGreen = Color(0xFF00C853);
  static const Color warningAmber = Color(0xFFFFC107);

  // ─── Utility ────────────────────────────────────────────────────────
  static Color withOpacity(Color c, double opacity) =>
      c.withValues(alpha: opacity);

  // ─── Theme Data ────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: primaryPurple,
      secondary: primaryBlue,
      tertiary: accentTeal,
      surface: bgCard,
      error: neonRed,
      onSurface:
          Colors.white, // Added to guarantee text visibility in dark mode
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    cardTheme: CardThemeData(
      color: bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      shadowColor: primaryPurple.withValues(alpha: 0.15),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: textLightMuted),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: bgCard, // Fixed to fit dark theme logic correctly
      selectedItemColor: primaryPurple,
      unselectedItemColor: navInactive,
      type: BottomNavigationBarType.fixed,
      elevation: 20,
    ),
  );

  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: bgLight,
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primaryPurple,
      secondary: primaryBlue,
      tertiary: accentTeal,
      surface: bgLightSurface,
      error: neonRed,
      onSurface:
          textLightPrimary, // Added to guarantee text visibility in light mode
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textLightPrimary),
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: textLightPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.06),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgLightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: textLightMuted),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryPurple,
      unselectedItemColor: navInactive,
      type: BottomNavigationBarType.fixed,
      elevation: 20,
    ),
  );
}
