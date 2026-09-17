import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SystemColors {
  // --- Dark Mode Base Colors (Shadow Monarch Theme) ---
  static const Color background = Color(0xFF050811);
  static const Color panelBg = Color(0xFF0C1427);
  static const Color panelBgTranslucent = Color(0xCC0C1427);
  static const Color panelBorder = Color(0xFF1E3A5F);

  // --- Light Mode Base Colors (Radiant System Theme) ---
  static const Color lightBackground = Color(0xFFF1F5F9);
  static const Color lightPanelBg = Color(0xFFFFFFFF);
  static const Color lightPanelBgTranslucent = Color(0xF2FFFFFF);
  static const Color lightPanelBorder = Color(0xFFCBD5E1);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);
  static const Color lightCyanGlow = Color(0xFF0284C7);
  static const Color lightBlueGlow = Color(0xFF0369A1);
  
  // --- Accent Glows ---
  static const Color cyanGlow = Color(0xFF00F0FF);
  static const Color blueGlow = Color(0xFF0084FF);
  static const Color darkBlue = Color(0xFF0E223D);

  static const Color crimsonGlow = Color(0xFFFF1E56);
  static const Color crimsonDark = Color(0xFF2A0812);
  static const Color monarchViolet = Color(0xFF9D4EDD);
  static const Color monarchPurple = Color(0xFFA855F7);
  static const Color monarchDark = Color(0xFF19092B);
  static const Color shadowBlack = Color(0xFF03050C);

  // Backward compatibility alias
  static const Color penaltyRed = crimsonGlow;
  static const Color penaltyDark = crimsonDark;
  
  static const Color goldAccent = Color(0xFFFFD700);
  static const Color purpleShadow = monarchPurple;

  static const Color textPrimary = Color(0xFFE5F4FF);
  static const Color textSecondary = Color(0xFF7E97B8);
  static const Color textMuted = Color(0xFF435B7D);

  static const Color hpGreen = Color(0xFF00E676);
  static const Color mpBlue = Color(0xFF2979FF);
  static const Color fatigueAmber = Color(0xFFFF9100);
}

class SystemTheme {
  /// Check if context is currently using Dark Theme
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color getBackground(BuildContext context) =>
      isDark(context) ? SystemColors.background : SystemColors.lightBackground;

  static Color getPanelBg(BuildContext context) =>
      isDark(context) ? SystemColors.panelBg : SystemColors.lightPanelBg;

  static Color getPanelBgTranslucent(BuildContext context) =>
      isDark(context) ? SystemColors.panelBgTranslucent : SystemColors.lightPanelBgTranslucent;

  static Color getPanelBorder(BuildContext context) =>
      isDark(context) ? SystemColors.panelBorder : SystemColors.lightPanelBorder;

  static Color getTextPrimary(BuildContext context) =>
      isDark(context) ? SystemColors.textPrimary : SystemColors.lightTextPrimary;

  static Color getTextSecondary(BuildContext context) =>
      isDark(context) ? SystemColors.textSecondary : SystemColors.lightTextSecondary;

  static Color getTextMuted(BuildContext context) =>
      isDark(context) ? SystemColors.textMuted : SystemColors.lightTextMuted;

  static Color getPrimaryAccent(BuildContext context) =>
      isDark(context) ? SystemColors.cyanGlow : SystemColors.lightCyanGlow;

  /// Signature Shadow Monarch Dark Theme
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: SystemColors.background,
      primaryColor: SystemColors.cyanGlow,
      colorScheme: const ColorScheme.dark(
        primary: SystemColors.cyanGlow,
        secondary: SystemColors.blueGlow,
        surface: SystemColors.panelBg,
        error: SystemColors.crimsonGlow,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: SystemColors.panelBg,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: SystemColors.panelBg,
      ),
      textTheme: GoogleFonts.rajdhaniTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.orbitron(
          color: SystemColors.cyanGlow,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
        headlineMedium: GoogleFonts.orbitron(
          color: SystemColors.textPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        titleLarge: GoogleFonts.orbitron(
          color: SystemColors.cyanGlow,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        bodyLarge: GoogleFonts.rajdhani(
          color: SystemColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: GoogleFonts.rajdhani(
          color: SystemColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// High-Tech Radiant Hunter System Light Theme
  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: SystemColors.lightBackground,
      primaryColor: SystemColors.lightCyanGlow,
      colorScheme: const ColorScheme.light(
        primary: SystemColors.lightCyanGlow,
        secondary: SystemColors.lightBlueGlow,
        surface: SystemColors.lightPanelBg,
        error: SystemColors.crimsonGlow,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: SystemColors.lightPanelBg,
        foregroundColor: SystemColors.lightTextPrimary,
        elevation: 0,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: SystemColors.lightPanelBg,
      ),
      textTheme: GoogleFonts.rajdhaniTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.orbitron(
          color: SystemColors.lightCyanGlow,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
        headlineMedium: GoogleFonts.orbitron(
          color: SystemColors.lightTextPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        titleLarge: GoogleFonts.orbitron(
          color: SystemColors.lightCyanGlow,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        bodyLarge: GoogleFonts.rajdhani(
          color: SystemColors.lightTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: GoogleFonts.rajdhani(
          color: SystemColors.lightTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static BoxDecoration holographicPanel({
    Color borderColor = SystemColors.cyanGlow,
    double glowOpacity = 0.25,
    double radius = 10.0,
    bool isDark = true,
  }) {
    return BoxDecoration(
      color: isDark ? SystemColors.panelBgTranslucent : SystemColors.lightPanelBgTranslucent,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor.withValues(alpha: isDark ? 0.6 : 0.8),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: borderColor.withValues(alpha: isDark ? glowOpacity : glowOpacity * 0.7),
          blurRadius: 12,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: isDark ? Colors.black54 : Colors.black12,
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    );
  }

  static BoxDecoration deadlyPanel({bool isDark = true}) {
    return holographicPanel(
      borderColor: SystemColors.crimsonGlow,
      glowOpacity: 0.35,
      isDark: isDark,
    );
  }

  static BoxDecoration penaltyPanel({bool isDark = true}) => deadlyPanel(isDark: isDark);
}
