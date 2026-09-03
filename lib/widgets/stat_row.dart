import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quest_model.dart';
import '../theme/system_theme.dart';

class StatRow extends StatelessWidget {
  final StatType statType;
  final int value;
  final int availablePoints;
  final VoidCallback onAdd;

  const StatRow({
    super.key,
    required this.statType,
    required this.value,
    required this.availablePoints,
    required this.onAdd,
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
            const Spacer(),
            Text(
              '$value',
              style: GoogleFonts.orbitron(
                color: SystemColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 12),
            if (availablePoints > 0)
              InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(4.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SystemColors.cyanGlow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4.0),
                    border: Border.all(
                      color: SystemColors.cyanGlow,
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: SystemColors.cyanGlow.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, color: SystemColors.cyanGlow, size: 14),
                      Text(
                        'ALLOC',
                        style: GoogleFonts.orbitron(
                          color: SystemColors.cyanGlow,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const SizedBox(width: 28),
          ],
        ),
      ),
    );
  }
}
