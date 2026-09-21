import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quest_model.dart';
import '../theme/system_theme.dart';

class StatRow extends StatelessWidget {
  final StatType statType;
  final int value;
  final int gainsFromTasks;

  const StatRow({
    super.key,
    required this.statType,
    required this.value,
    this.gainsFromTasks = 0,
  });

  IconData _getIcon() {
    switch (statType) {
      case StatType.str:
        return Icons.fitness_center;
      case StatType.agi:
        return Icons.bolt;
      case StatType.vit:
        return Icons.favorite;
      case StatType.intl:
        return Icons.psychology;
      case StatType.per:
        return Icons.visibility;
    }
  }

  Color _getColor(bool isDark) {
    switch (statType) {
      case StatType.str:
        return isDark ? const Color(0xFFFF5252) : const Color(0xFFE11D48);
      case StatType.agi:
        return isDark ? const Color(0xFFFFD740) : const Color(0xFFD97706);
      case StatType.vit:
        return isDark ? const Color(0xFF69F0AE) : const Color(0xFF059669);
      case StatType.intl:
        return isDark ? const Color(0xFF448AFF) : const Color(0xFF2563EB);
      case StatType.per:
        return isDark ? const Color(0xFFE040FB) : const Color(0xFF9333EA);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = SystemTheme.isDark(context);
    final color = _getColor(isDark);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isDark ? SystemColors.panelBg.withValues(alpha: 0.6) : Colors.white,
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.3 : 0.45),
            width: isDark ? 1.0 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : const Color(0x080F172A),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(_getIcon(), color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              statType.code,
              style: GoogleFonts.orbitron(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${statType.label})',
              style: GoogleFonts.rajdhani(
                color: SystemTheme.getTextSecondary(context),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            if (gainsFromTasks > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color.withValues(alpha: 0.5), width: 0.8),
                ),
                child: Text(
                  '+$gainsFromTasks Task${gainsFromTasks > 1 ? 's' : ''}',
                  style: GoogleFonts.orbitron(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const Spacer(),
            Text(
              '$value',
              style: GoogleFonts.orbitron(
                color: SystemTheme.getTextPrimary(context),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}
