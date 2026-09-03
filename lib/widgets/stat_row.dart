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

  Color _getColor() {
    switch (statType) {
      case StatType.str:
        return const Color(0xFFFF5252);
      case StatType.agi:
        return const Color(0xFFFFD740);
      case StatType.vit:
        return const Color(0xFF69F0AE);
      case StatType.intl:
        return const Color(0xFF448AFF);
      case StatType.per:
        return const Color(0xFFE040FB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: SystemColors.panelBg.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.0,
          ),
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
                color: SystemColors.textSecondary,
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
                color: SystemColors.textPrimary,
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
