import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/system_theme.dart';
import '../models/achievement_model.dart';

class AchievementDialog extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback onDismiss;

  const AchievementDialog({
    super.key,
    required this.achievement,
    required this.onDismiss,
  });

  @override
  State<AchievementDialog> createState() => _AchievementDialogState();
}

class _AchievementDialogState extends State<AchievementDialog>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _badgeController;
  late Animation<double> _glowAnim;
  late Animation<double> _badgeScale;
  late Animation<double> _badgeRotation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _badgeScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.elasticOut),
    );

    _badgeRotation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  Color _tierColor(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return SystemColors.goldAccent;
      case AchievementTier.legendary:
        return SystemColors.purpleShadow;
    }
  }

  String _tierLabel(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return 'BRONZE';
      case AchievementTier.silver:
        return 'SILVER';
      case AchievementTier.gold:
        return 'GOLD';
      case AchievementTier.legendary:
        return 'LEGENDARY';
    }
  }

  @override
  Widget build(BuildContext context) {
    final achievement = widget.achievement;
    final tierColor = _tierColor(achievement.tier);

    return AnimatedBuilder(
      animation: Listenable.merge([_glowController, _badgeController]),
      builder: (context, child) {
        return Container(
          color: Colors.black.withValues(alpha: 0.9),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24.0),
              padding: const EdgeInsets.all(28.0),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A1A),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: tierColor.withValues(alpha: _glowAnim.value),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: tierColor.withValues(alpha: _glowAnim.value * 0.5),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: tierColor.withValues(alpha: _glowAnim.value * 0.2),
                    blurRadius: 80,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Achievement Header
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: tierColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: tierColor.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'ACHIEVEMENT UNLOCKED',
                      style: GoogleFonts.orbitron(
                        color: tierColor,
                        fontSize: 12,
                        letterSpacing: 3.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Badge with animation
                  Transform.scale(
                    scale: _badgeScale.value,
                    child: Transform.rotate(
                      angle: _badgeRotation.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: tierColor.withValues(alpha: 0.15),
                          border: Border.all(
                            color: tierColor,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: tierColor
                                  .withValues(alpha: _glowAnim.value * 0.6),
                              blurRadius: 20,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            achievement.badge,
                            style: const TextStyle(fontSize: 36),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Tier label
                  Text(
                    _tierLabel(achievement.tier),
                    style: GoogleFonts.orbitron(
                      color: tierColor,
                      fontSize: 11,
                      letterSpacing: 4.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Achievement Title
                  Text(
                    achievement.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(
                          color: tierColor.withValues(alpha: 0.8),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    achievement.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rajdhani(
                      color: SystemColors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Rewards
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: tierColor.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'REWARDS CLAIMED',
                          style: GoogleFonts.orbitron(
                            color: tierColor,
                            fontSize: 10,
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildRewardChip(
                              '+${achievement.expReward} EXP',
                              Icons.bolt,
                              SystemColors.cyanGlow,
                            ),
                            const SizedBox(width: 10),
                            _buildRewardChip(
                              '+${achievement.goldReward} Gold',
                              Icons.monetization_on,
                              SystemColors.goldAccent,
                            ),
                          ],
                        ),
                        if (achievement.titleReward != null) ...[
                          const SizedBox(height: 8),
                          _buildRewardChip(
                            'Title: ${achievement.titleReward}',
                            Icons.military_tech,
                            SystemColors.purpleShadow,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Dismiss
                  ElevatedButton(
                    onPressed: widget.onDismiss,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tierColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 10,
                      shadowColor: tierColor,
                    ),
                    child: Text(
                      'ACCEPT',
                      style: GoogleFonts.orbitron(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 2.0,
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

  Widget _buildRewardChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
