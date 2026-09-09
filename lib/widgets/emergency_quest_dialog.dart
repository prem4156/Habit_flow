import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/system_theme.dart';
import '../models/quest_model.dart';

class EmergencyQuestDialog extends StatefulWidget {
  final Quest emergencyQuest;
  final VoidCallback onDismiss;
  final VoidCallback onAccept;

  const EmergencyQuestDialog({
    super.key,
    required this.emergencyQuest,
    required this.onDismiss,
    required this.onAccept,
  });

  @override
  State<EmergencyQuestDialog> createState() => _EmergencyQuestDialogState();
}

class _EmergencyQuestDialogState extends State<EmergencyQuestDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _pulseAnim;
  late Animation<double> _scanlineAnim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeInOut),
    );
    _scanlineAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _anim, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quest = widget.emergencyQuest;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return Container(
          color: Colors.black.withValues(alpha: 0.94),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A1A),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: Color.lerp(
                    SystemColors.penaltyRed,
                    SystemColors.cyanGlow,
                    _pulseAnim.value * 0.3,
                  )!,
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: SystemColors.penaltyRed
                        .withValues(alpha: _pulseAnim.value * 0.6),
                    blurRadius: 35,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: SystemColors.cyanGlow
                        .withValues(alpha: _pulseAnim.value * 0.15),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9.0),
                child: Stack(
                  children: [
                    // Scanline effect
                    Positioned(
                      left: 0,
                      right: 0,
                      top: _scanlineAnim.value * 400,
                      child: Container(
                        height: 2,
                        color: SystemColors.cyanGlow.withValues(alpha: 0.08),
                      ),
                    ),
                    // Main content
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // System Message Header
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color:
                                  SystemColors.penaltyRed.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: SystemColors.penaltyRed
                                    .withValues(alpha: _pulseAnim.value),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: SystemColors.penaltyRed
                                      .withValues(alpha: _pulseAnim.value),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'SYSTEM MESSAGE',
                                  style: GoogleFonts.orbitron(
                                    color: SystemColors.penaltyRed,
                                    fontSize: 13,
                                    letterSpacing: 3.0,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: SystemColors.penaltyRed
                                      .withValues(alpha: _pulseAnim.value),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Urgent Reason
                          Text(
                            quest.urgentReason ??
                                'Player has demonstrated insufficient discipline.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.rajdhani(
                              color: SystemColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Emergency Quest Title
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: SystemColors.cyanGlow
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'NEW EMERGENCY QUEST GENERATED',
                                  style: GoogleFonts.orbitron(
                                    color: SystemColors.cyanGlow,
                                    fontSize: 11,
                                    letterSpacing: 2.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  quest.title.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.orbitron(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                    shadows: [
                                      Shadow(
                                        color: SystemColors.cyanGlow
                                            .withValues(alpha: 0.6),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  quest.description,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.rajdhani(
                                    color: SystemColors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildInfoChip(
                                        '${quest.target} ${quest.unit}',
                                        Icons.track_changes),
                                    const SizedBox(width: 12),
                                    _buildInfoChip(
                                        '+${quest.expReward} EXP',
                                        Icons.bolt),
                                    const SizedBox(width: 12),
                                    _buildInfoChip(
                                        '+2 ${quest.statReward.code}',
                                        Icons.trending_up),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Deadline
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: SystemColors.penaltyRed
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: SystemColors.penaltyRed
                                    .withValues(alpha: _pulseAnim.value * 0.8),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer,
                                  color: SystemColors.penaltyRed,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'COMPLETE BEFORE ',
                                  style: GoogleFonts.orbitron(
                                    color: SystemColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  quest.deadline ?? '23:59',
                                  style: GoogleFonts.orbitron(
                                    color: SystemColors.penaltyRed,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Actions
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: widget.onDismiss,
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: Colors.white
                                            .withValues(alpha: 0.3)),
                                    foregroundColor: Colors.white60,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                  child: Text(
                                    'DISMISS',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: widget.onAccept,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: SystemColors.penaltyRed,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    elevation: 10,
                                    shadowColor: SystemColors.penaltyRed,
                                  ),
                                  child: Text(
                                    'ACCEPT DIRECTIVE',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: SystemColors.cyanGlow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border:
            Border.all(color: SystemColors.cyanGlow.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: SystemColors.cyanGlow, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.orbitron(
              color: SystemColors.cyanGlow,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
