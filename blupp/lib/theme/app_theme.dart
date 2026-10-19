import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/currency_model.dart';

class AppTheme {
  // Global Theme Mode State
  static bool isDark = true;
  static String activeCurrencyCode = 'MYR';

  // ─── Emil Kowalski Zinc Palette ───────────────────────────────────
  // Dark: near-black base, warm zinc grays
  // Light: clean white base, cool zinc grays

  static Color get background => isDark ? const Color(0xFF09090B) : const Color(0xFFFAFAFA);
  static Color get surface => isDark ? const Color(0xFF18181B) : const Color(0xFFFFFFFF);
  static Color get surfaceLight => isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
  static Color get surfaceBorder => isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7);

  // ─── Accent: Desaturated Emerald (single primary) ─────────────────
  static const Color primaryTeal = Color(0xFF10B981);
  static const Color primaryTealGlow = Color(0x1A10B981);

  // ─── Functional Colors (muted, used sparingly) ────────────────────
  static const Color secondaryCyan = Color(0xFF06B6D4);
  static const Color expenseCoral = Color(0xFFEF4444);
  static const Color incomeMint = Color(0xFF22C55E);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color fomoPurple = Color(0xFF8B5CF6);
  static const Color fomoPurpleGlow = Color(0x1A8B5CF6);

  // ─── Text: Clean hierarchy ────────────────────────────────────────
  static Color get textPrimary => isDark ? const Color(0xFFFAFAFA) : const Color(0xFF09090B);
  static Color get textSecondary => isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
  static Color get textMuted => isDark ? const Color(0xFF71717A) : const Color(0xFFA1A1AA);

  // ─── Card Decoration: Flat, subtle border, no glow ────────────────
  static BoxDecoration cardDecoration({
    Color? borderColor,
    Gradient? gradient,
    double radius = 12.0,
  }) {
    return BoxDecoration(
      color: gradient == null ? surface : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? surfaceBorder.withValues(alpha: isDark ? 0.5 : 0.8),
        width: 1.0,
      ),
    );
  }

  // ─── Glow Card: Now just a slightly elevated flat card ────────────
  static BoxDecoration glowCard({
    required Color glowColor,
    double radius = 12.0,
  }) {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: glowColor.withValues(alpha: isDark ? 0.2 : 0.3),
        width: 1.0,
      ),
    );
  }

  // ─── Inter Font Text Theme ────────────────────────────────────────
  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseTheme = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;
    return GoogleFonts.interTextTheme(baseTheme);
  }

  // ─── Dark Theme ───────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF09090B),
      textTheme: _buildTextTheme(Brightness.dark),
      colorScheme: const ColorScheme.dark(
        primary: primaryTeal,
        secondary: secondaryCyan,
        surface: Color(0xFF18181B),
        onSurface: Color(0xFFFAFAFA),
        error: expenseCoral,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF09090B),
        foregroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.inter(
          color: const Color(0xFFFAFAFA),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF18181B),
        selectedItemColor: primaryTeal,
        unselectedItemColor: Color(0xFF71717A),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
    );
  }

  // ─── Light Theme ──────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      textTheme: _buildTextTheme(Brightness.light),
      colorScheme: const ColorScheme.light(
        primary: primaryTeal,
        secondary: secondaryCyan,
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF09090B),
        error: expenseCoral,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFAFAFA),
        foregroundColor: const Color(0xFF09090B),
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.inter(
          color: const Color(0xFF09090B),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFFFFFFF),
        selectedItemColor: primaryTeal,
        unselectedItemColor: Color(0xFFA1A1AA),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
    );
  }

  // Backward compatibility getter
  static ThemeData get themeData => isDark ? darkTheme : lightTheme;

  // Currency Formatter Helper (Dynamic multi-currency support)
  static String formatCurrency(double amount, {String? currencyCode}) {
    final code = currencyCode ?? activeCurrencyCode;
    return CurrencyManager.format(amount, code);
  }
}
