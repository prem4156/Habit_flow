import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SystemColors {
  static const Color background = Color(0xFF050811);
  static const Color panelBg = Color(0xFF0C1427);
  static const Color panelBgTranslucent = Color(0xCC0C1427);
  static const Color panelBorder = Color(0xFF1E3A5F);
  
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

  static BoxDecoration holographicPanel({
    Color borderColor = SystemColors.cyanGlow,
    double glowOpacity = 0.25,
    double radius = 10.0,
  }) {
    return BoxDecoration(
      color: SystemColors.panelBgTranslucent,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor.withValues(alpha: 0.6),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: borderColor.withValues(alpha: glowOpacity),
          blurRadius: 12,
          spreadRadius: 1,
        ),
        const BoxShadow(
          color: Colors.black54,
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    );
  }

  static BoxDecoration deadlyPanel() {
    return holographicPanel(
      borderColor: SystemColors.crimsonGlow,
      glowOpacity: 0.35,
    );
  }

  static BoxDecoration penaltyPanel() => deadlyPanel();
}
