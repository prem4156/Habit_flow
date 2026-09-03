import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/system_theme.dart';

class PenaltyDialog extends StatefulWidget {
  final int timeRemainingSeconds;
  final VoidCallback onSurvive;
  final VoidCallback onEscape;

  const PenaltyDialog({
    super.key,
    required this.timeRemainingSeconds,
    required this.onSurvive,
    required this.onEscape,
  });

  @override
  State<PenaltyDialog> createState() => _PenaltyDialogState();
}

class _PenaltyDialogState extends State<PenaltyDialog> with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  String _formatTimer(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final glow = 0.3 + (_anim.value * 0.6);
        return Container(
          color: Colors.black.withValues(alpha: 0.92),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: SystemColors.penaltyDark,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: SystemColors.penaltyRed,
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: SystemColors.penaltyRed.withValues(alpha: glow),
                    blurRadius: 30,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Warning Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: SystemColors.penaltyRed, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'WARNING: SYSTEM PENALTY',
                        style: GoogleFonts.orbitron(
                          color: SystemColors.penaltyRed,
                          fontSize: 14,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.warning_amber_rounded, color: SystemColors.penaltyRed, size: 24),
                    ],
                  ),
                  const SizedBox(height: 18),

                  Text(
                    '[ PENALTY QUEST ]',
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SURVIVAL IN THE DESERT REALM',
                    style: GoogleFonts.rajdhani(
                      color: SystemColors.penaltyRed,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Timer Countdown Display
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: SystemColors.penaltyRed.withValues(alpha: 0.6)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'TIME REMAINING UNTIL SANCTUARY',
                          style: GoogleFonts.orbitron(
                            color: SystemColors.textSecondary,
                            fontSize: 10,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatTimer(widget.timeRemainingSeconds),
                          style: GoogleFonts.orbitron(
                            color: SystemColors.penaltyRed,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Giant Poison-Tailed Centipedes are pursuing you.\nComplete an emergency habit sprint or endure until time elapses!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rajdhani(
                      color: SystemColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onEscape,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                            foregroundColor: Colors.white70,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'EMERGENCY EXIT',
                            style: GoogleFonts.orbitron(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.onSurvive,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SystemColors.penaltyRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 8,
                          ),
                          child: Text(
                            'SURVIVED CHALLENGE',
                            style: GoogleFonts.orbitron(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
