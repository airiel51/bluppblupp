import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/currency_model.dart';

class AppTheme {
  // Global Theme Mode State
  static bool isDark = true;
  static String activeCurrencyCode = 'MYR';

  // ─── Modern Fintech Palette (Inspired by Elizaveta Akhmetova) ──────
  // Dark: Deep midnight obsidian base, sleek charcoal cards
  // Light: Crisp modern porcelain base, soft neutral grays

  static Color get background => isDark ? const Color(0xFF0C0D12) : const Color(0xFFF8F9FA);
  static Color get surface => isDark ? const Color(0xFF161720) : const Color(0xFFFFFFFF);
  static Color get surfaceLight => isDark ? const Color(0xFF1E202B) : const Color(0xFFF1F3F5);
  static Color get surfaceBorder => isDark ? const Color(0xFF282A37) : const Color(0xFFE2E4E9);

  // ─── Gradients & Hero Palettes ────────────────────────────────────
  static const LinearGradient heroVioletGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF382BF0),
      Color(0xFF23187C),
      Color(0xFF150E45),
    ],
  );

  static const LinearGradient sunsetCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF472B6),
      Color(0xFFFB923C),
      Color(0xFFF43F5E),
    ],
  );

  static const LinearGradient purpleSunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
      Color(0xFFF59E0B),
    ],
  );

  // ─── Accents & Functional Colors ──────────────────────────────────
  static const Color primaryTeal = Color(0xFF10B981);
  static const Color primaryTealGlow = Color(0x1A10B981);
  static const Color accentMint = Color(0xFF4ADE80);
  static const Color accentCoral = Color(0xFFFF6B4A);
  static const Color accentAmber = Color(0xFFFBBF24);
  static const Color accentBlue = Color(0xFF60A5FA);
  static const Color secondaryCyan = Color(0xFF06B6D4);
  static const Color expenseCoral = Color(0xFFFF4D4D);
  static const Color incomeMint = Color(0xFF4ADE80);
  static const Color warningAmber = Color(0xFFFBBF24);
  static const Color fomoPurple = Color(0xFF8B5CF6);
  static const Color fomoPurpleGlow = Color(0x1A8B5CF6);

  // ─── Text: Clean hierarchy ────────────────────────────────────────
  static Color get textPrimary => isDark ? const Color(0xFFFDFDFE) : const Color(0xFF0F1015);
  static Color get textSecondary => isDark ? const Color(0xFFA6A8B4) : const Color(0xFF6C727F);
  static Color get textMuted => isDark ? const Color(0xFF707382) : const Color(0xFF9CA3AF);

  // ─── Card Decoration: Rounded, sleek border ───────────────────────
  static BoxDecoration cardDecoration({
    Color? borderColor,
    Gradient? gradient,
    double radius = 20.0,
  }) {
    return BoxDecoration(
      color: gradient == null ? surface : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? surfaceBorder.withValues(alpha: isDark ? 0.7 : 0.9),
        width: 1.0,
      ),
    );
  }

  // ─── Glow Card ────────────────────────────────────────────────────
  static BoxDecoration glowCard({
    required Color glowColor,
    double radius = 20.0,
  }) {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: glowColor.withValues(alpha: isDark ? 0.3 : 0.4),
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
      scaffoldBackgroundColor: const Color(0xFF0C0D12),
      textTheme: _buildTextTheme(Brightness.dark),
      colorScheme: const ColorScheme.dark(
        primary: primaryTeal,
        secondary: secondaryCyan,
        surface: Color(0xFF161720),
        onSurface: Color(0xFFFDFDFE),
        error: expenseCoral,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0C0D12),
        foregroundColor: const Color(0xFFFDFDFE),
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
