import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SystemColors {
  // --- Dark Mode Base Colors (Shadow Monarch Theme) ---
  static const Color background = Color(0xFF050811);
  static const Color panelBg = Color(0xFF0C1427);
  static const Color panelBgTranslucent = Color(0xCC0C1427);
  static const Color panelBorder = Color(0xFF1E3A5F);

  // --- Light Mode Base Colors (Radiant Crystal System Theme) ---
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightPanelBg = Color(0xFFFFFFFF);
  static const Color lightPanelBgTranslucent = Color(0xF7FFFFFF);
  static const Color lightPanelBorder = Color(0xFFCBD5E1);
  static const Color lightCardBg = Color(0xFFF1F5F9);
  static const Color lightProgressTrack = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF334155);
  static const Color lightTextMuted = Color(0xFF64748B);
  static const Color lightCyanGlow = Color(0xFF0284C7);
  static const Color lightBlueGlow = Color(0xFF2563EB);
  static const Color lightDarkBlue = Color(0xFF0369A1);
  static const Color lightGoldAccent = Color(0xFFD97706);
  static const Color lightHpGreen = Color(0xFF16A34A);
  static const Color lightCrimson = Color(0xFFE11D48);
  static const Color lightMonarchPurple = Color(0xFF7C3AED);
  static const Color lightMonarchViolet = Color(0xFF9333EA);
  static const Color lightFatigueAmber = Color(0xFFD97706);
  static const Color lightMpBlue = Color(0xFF2563EB);
  
  // --- Accent Glows (Dark Mode) ---
  static const Color cyanGlow = Color(0xFF00F0FF);
  static const Color blueGlow = Color(0xFF0084FF);
  static const Color darkBlue = Color(0xFF0E223D);

  static const Color crimsonGlow = Color(0xFFFF1E56);
  static const Color crimsonDark = Color(0xFF2A0812);
  static const Color monarchViolet = Color(0xFF9D4EDD);
  static const Color monarchPurple = Color(0xFFA855F7);
  static const Color monarchDark = Color(0xFF19092B);
  static const Color shadowBlack = Color(0xFF03050C);

  // Backward compatibility aliases
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

  static Color getCardBg(BuildContext context) =>
      isDark(context) ? Colors.black26 : SystemColors.lightCardBg;

  static Color getProgressTrack(BuildContext context) =>
      isDark(context) ? Colors.black45 : SystemColors.lightProgressTrack;

  static Color getTextPrimary(BuildContext context) =>
      isDark(context) ? SystemColors.textPrimary : SystemColors.lightTextPrimary;

  static Color getTextSecondary(BuildContext context) =>
      isDark(context) ? SystemColors.textSecondary : SystemColors.lightTextSecondary;

  static Color getTextMuted(BuildContext context) =>
      isDark(context) ? SystemColors.textMuted : SystemColors.lightTextMuted;

  static Color getPrimaryAccent(BuildContext context) =>
      isDark(context) ? SystemColors.cyanGlow : SystemColors.lightCyanGlow;

  static Color getSecondaryAccent(BuildContext context) =>
      isDark(context) ? SystemColors.blueGlow : SystemColors.lightBlueGlow;

  static Color getGoldAccent(BuildContext context) =>
      isDark(context) ? SystemColors.goldAccent : SystemColors.lightGoldAccent;

  static Color getGreenAccent(BuildContext context) =>
      isDark(context) ? SystemColors.hpGreen : SystemColors.lightHpGreen;

  static Color getPurpleAccent(BuildContext context) =>
      isDark(context) ? SystemColors.monarchPurple : SystemColors.lightMonarchPurple;

  static Color getCrimsonAccent(BuildContext context) =>
      isDark(context) ? SystemColors.crimsonGlow : SystemColors.lightCrimson;

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
      cardColor: SystemColors.lightPanelBg,
      dividerColor: SystemColors.lightPanelBorder,
      colorScheme: const ColorScheme.light(
        primary: SystemColors.lightCyanGlow,
        secondary: SystemColors.lightBlueGlow,
        surface: SystemColors.lightPanelBg,
        error: SystemColors.lightCrimson,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: SystemColors.lightPanelBg,
        foregroundColor: SystemColors.lightTextPrimary,
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: SystemColors.lightPanelBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: SystemColors.lightCyanGlow, width: 1.4),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SystemColors.lightCardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: SystemColors.lightPanelBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: SystemColors.lightPanelBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: SystemColors.lightCyanGlow, width: 1.5),
        ),
        labelStyle: GoogleFonts.rajdhani(color: SystemColors.lightTextSecondary, fontWeight: FontWeight.w600),
        hintStyle: GoogleFonts.rajdhani(color: SystemColors.lightTextMuted),
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
    final effectiveBorder = !isDark && borderColor == SystemColors.cyanGlow
        ? SystemColors.lightCyanGlow
        : borderColor;
    return BoxDecoration(
      color: isDark ? SystemColors.panelBgTranslucent : SystemColors.lightPanelBgTranslucent,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: effectiveBorder.withValues(alpha: isDark ? 0.6 : 0.8),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: effectiveBorder.withValues(alpha: isDark ? glowOpacity : glowOpacity * 0.35),
          blurRadius: 14,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: isDark ? Colors.black54 : const Color(0x0D0F172A),
          blurRadius: 12,
          offset: const Offset(0, 3),
          spreadRadius: isDark ? 2 : 0,
        ),
      ],
    );
  }

  static BoxDecoration deadlyPanel({bool isDark = true}) {
    return holographicPanel(
      borderColor: isDark ? SystemColors.crimsonGlow : SystemColors.lightCrimson,
      glowOpacity: 0.35,
      isDark: isDark,
    );
  }

  static BoxDecoration penaltyPanel({bool isDark = true}) => deadlyPanel(isDark: isDark);
}
