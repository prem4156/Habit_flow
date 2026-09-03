import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/system_theme.dart';

class LevelUpDialog extends StatefulWidget {
  final int newLevel;
  final VoidCallback onDismiss;

  const LevelUpDialog({
    super.key,
    required this.newLevel,
    required this.onDismiss,
  });

  @override
  State<LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<LevelUpDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.85).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Container(
          color: Colors.black.withValues(alpha: 0.85),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24.0),
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: SystemColors.panelBg,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: SystemColors.cyanGlow,
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: SystemColors.cyanGlow.withValues(alpha: _glowAnimation.value),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // System Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: SystemColors.cyanGlow.withValues(alpha: 0.15),
                      border: Border.all(color: SystemColors.cyanGlow, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'SYSTEM NOTIFICATION',
                      style: GoogleFonts.orbitron(
                        color: SystemColors.cyanGlow,
                        fontSize: 12,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Iconic [ LEVEL UP! ]
                  Text(
                    '[ LEVEL UP! ]',
                    style: GoogleFonts.orbitron(
                      color: SystemColors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.0,
                      shadows: [
                        Shadow(
                          color: SystemColors.cyanGlow,
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Hunter has advanced to Level ${widget.newLevel}',
                    style: GoogleFonts.rajdhani(
                      color: SystemColors.cyanGlow,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // System Perks granted
                  _buildPerkRow(Icons.bolt, 'Hunter Rank & Max Mana Capacities Elevated'),
                  _buildPerkRow(Icons.favorite, 'Max HP & Stamina Capacities Increased'),
                  _buildPerkRow(Icons.shield_moon, 'Physical Fatigue Alleviated by 20%'),
                  const SizedBox(height: 24),

                  // Confirm Button
                  ElevatedButton(
                    onPressed: widget.onDismiss,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SystemColors.cyanGlow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 8,
                      shadowColor: SystemColors.cyanGlow,
                    ),
                    child: Text(
                      'ACCEPT NOTIFICATION',
                      style: GoogleFonts.orbitron(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerkRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: SystemColors.cyanGlow, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.rajdhani(
                color: SystemColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
