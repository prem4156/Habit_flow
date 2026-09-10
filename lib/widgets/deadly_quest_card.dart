import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quest_model.dart';
import '../services/system_state.dart';
import '../theme/system_theme.dart';
import 'habit_day_tracker_grid.dart';

class DeadlyQuestCard extends StatefulWidget {
  final Quest quest;
  final DateTime date;
  final SystemState state;
  final VoidCallback onAttributeTap;
  final bool isCompleted;

  const DeadlyQuestCard({
    super.key,
    required this.quest,
    required this.date,
    required this.state,
    required this.onAttributeTap,
    this.isCompleted = false,
  });

  @override
  State<DeadlyQuestCard> createState() => _DeadlyQuestCardState();
}

class _DeadlyQuestCardState extends State<DeadlyQuestCard>
    with TickerProviderStateMixin {
  late AnimationController _slashController;
  late AnimationController _shakeController;
  late AnimationController _floatingTextController;

  late Animation<double> _slashProgress;
  late Animation<double> _floatingOpacity;
  late Animation<double> _floatingOffsetY;
  late Animation<double> _floatingScale;

  bool _isPlayingDeadlyFx = false;

  @override
  void initState() {
    super.initState();

    // 1. Blade Slash Animation Controller (Swift & Sharp: 450ms)
    _slashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _slashProgress = CurvedAnimation(
      parent: _slashController,
      curve: Curves.easeOutQuart,
    );

    // 2. Micro Impact Shake Controller (Visceral feedback: 250ms)
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    // 3. Floating Combat Stat Upgrades Controller (Floating burst: 1200ms)
    _floatingTextController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _floatingOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_floatingTextController);

    _floatingOffsetY = Tween<double>(begin: 8.0, end: -36.0).animate(
      CurvedAnimation(parent: _floatingTextController, curve: Curves.easeOutCubic),
    );

    _floatingScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.15), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.95), weight: 60),
    ]).animate(_floatingTextController);
  }

  @override
  void dispose() {
    _slashController.dispose();
    _shakeController.dispose();
    _floatingTextController.dispose();
    super.dispose();
  }

  void _triggerDeadlyExecution({required VoidCallback onExecute}) {
    // 1. Visceral Tactile Heavy Impact
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}

    setState(() {
      _isPlayingDeadlyFx = true;
    });

    _slashController.forward(from: 0.0);
    _shakeController.forward(from: 0.0);
    _floatingTextController.forward(from: 0.0);

    // Perform state action
    onExecute();

    Future.delayed(const Duration(milliseconds: 1250), () {
      if (mounted) {
        setState(() {
          _isPlayingDeadlyFx = false;
        });
      }
    });
  }

  Color _getStatColor(StatType stat) {
    switch (stat) {
      case StatType.str:
        return SystemColors.crimsonGlow;
      case StatType.agi:
        return SystemColors.hpGreen;
      case StatType.vit:
        return SystemColors.fatigueAmber;
      case StatType.intl:
        return SystemColors.mpBlue;
      case StatType.per:
        return SystemColors.monarchViolet;
    }
  }

  @override
  Widget build(BuildContext context) {
    final quest = widget.quest;
    final date = widget.date;
    final isCustom = quest.id.startsWith('custom_');
    final statColor = _getStatColor(quest.statReward);

    if (widget.isCompleted) {
      return _buildCompletedCard(context, quest, date, statColor);
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _slashController,
        _shakeController,
        _floatingTextController,
      ]),
      builder: (context, child) {
        // Calculate dynamic shake offset
        double shakeDx = 0.0;
        if (_shakeController.isAnimating) {
          final s = sin(_shakeController.value * pi * 4);
          shakeDx = s * 3.5;
        }

        return Transform.translate(
          offset: Offset(shakeDx, 0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main Active Quest Card
              Container(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: _isPlayingDeadlyFx
                      ? SystemColors.monarchDark.withValues(alpha: 0.95)
                      : SystemColors.panelBg,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: _isPlayingDeadlyFx
                        ? SystemColors.crimsonGlow
                        : SystemColors.cyanGlow.withValues(alpha: 0.4),
                    width: _isPlayingDeadlyFx ? 1.8 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isPlayingDeadlyFx
                          ? SystemColors.monarchViolet.withValues(alpha: 0.5)
                          : SystemColors.cyanGlow.withValues(alpha: 0.08),
                      blurRadius: _isPlayingDeadlyFx ? 18 : 8,
                      spreadRadius: _isPlayingDeadlyFx ? 2 : 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Check circle, Title, Attribute Badge, Delete
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Deadly One-Tap Execution Button
                        InkWell(
                          onTap: () {
                            _triggerDeadlyExecution(
                              onExecute: () => widget.state.toggleQuestComplete(quest.id, date: date),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _isPlayingDeadlyFx
                                    ? SystemColors.crimsonGlow
                                    : SystemColors.cyanGlow,
                                width: 2,
                              ),
                              color: _isPlayingDeadlyFx
                                  ? SystemColors.crimsonGlow.withValues(alpha: 0.25)
                                  : Colors.black38,
                              boxShadow: [
                                BoxShadow(
                                  color: _isPlayingDeadlyFx
                                      ? SystemColors.crimsonGlow.withValues(alpha: 0.6)
                                      : SystemColors.cyanGlow.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                _isPlayingDeadlyFx ? Icons.offline_bolt : Icons.circle_outlined,
                                color: _isPlayingDeadlyFx
                                    ? SystemColors.crimsonGlow
                                    : SystemColors.cyanGlow.withValues(alpha: 0.6),
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Title & Description
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quest.title,
                                style: GoogleFonts.orbitron(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                quest.description,
                                style: GoogleFonts.rajdhani(
                                  color: SystemColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Interactive Attribute Badge (+1 STR ▾)
                        InkWell(
                          onTap: widget.onAttributeTap,
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: statColor.withValues(alpha: 0.6), width: 1.0),
                            ),
                            child: Row(
                              mainAxisSize: dynamicStatCodeRow(quest.statReward),
                              children: [
                                Text(
                                  '+1 ${quest.statReward.code}',
                                  style: GoogleFonts.orbitron(
                                    color: statColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(Icons.arrow_drop_down, color: statColor, size: 14),
                              ],
                            ),
                          ),
                        ),

                        // Delete option for custom quests
                        if (isCustom)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 16, color: Colors.white38),
                            onPressed: () => widget.state.deleteQuest(quest.id),
                            tooltip: 'Delete Habit',
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Progress Metric & Streak
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '[ ${quest.current} / ${quest.target} ${quest.unit} ]',
                              style: GoogleFonts.orbitron(
                                color: SystemColors.cyanGlow,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+${quest.expReward} EXP',
                              style: GoogleFonts.rajdhani(
                                color: SystemColors.goldAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (quest.streak > 0)
                          Row(
                            children: [
                              const Icon(Icons.local_fire_department, color: Colors.deepOrangeAccent, size: 14),
                              Text(
                                '${quest.streak}d Streak',
                                style: GoogleFonts.rajdhani(
                                  color: Colors.deepOrangeAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Linear Animated Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: quest.progress,
                        minHeight: 6,
                        backgroundColor: Colors.black45,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isPlayingDeadlyFx ? SystemColors.crimsonGlow : SystemColors.cyanGlow,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Day Tracker Grid (Heatmap Matrix below habit)
                    HabitDayTrackerGrid(
                      questId: quest.id,
                      state: widget.state,
                      activeColor: SystemColors.hpGreen,
                    ),

                    const SizedBox(height: 8),

                    // Quick Progression Stepper Buttons
                    _buildProgressButtons(context, quest, date),
                  ],
                ),
              ),

              // Deadly Blade Slash Overlay Painter
              if (_isPlayingDeadlyFx && _slashController.value > 0.0)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: DeadlySlashPainter(
                        progress: _slashProgress.value,
                        slashColor: SystemColors.crimsonGlow,
                        glowColor: SystemColors.monarchViolet,
                      ),
                    ),
                  ),
                ),

              // Floating Combat Stat Upgrade Banner
              if (_isPlayingDeadlyFx && _floatingTextController.value > 0.0)
                Positioned(
                  top: _floatingOffsetY.value,
                  left: 20,
                  right: 20,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: _floatingOpacity.value.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: _floatingScale.value,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: SystemColors.shadowBlack.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: SystemColors.crimsonGlow, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: SystemColors.crimsonGlow.withValues(alpha: 0.5),
                                  blurRadius: 14,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: SystemColors.monarchViolet.withValues(alpha: 0.4),
                                  blurRadius: 22,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('⚔ ', style: TextStyle(fontSize: 14)),
                                Text(
                                  'EXECUTED: ',
                                  style: GoogleFonts.orbitron(
                                    color: SystemColors.crimsonGlow,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Text(
                                  '+1 ${quest.statReward.code}',
                                  style: GoogleFonts.orbitron(
                                    color: statColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '• +${quest.expReward} EXP',
                                  style: GoogleFonts.rajdhani(
                                    color: SystemColors.goldAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  MainAxisSize dynamicStatCodeRow(StatType s) => MainAxisSize.min;

  // Completed Quest Card (Google Tasks style: Strikethrough, dim gunmetal, uncheck option)
  Widget _buildCompletedCard(
    BuildContext context,
    Quest quest,
    DateTime date,
    Color statColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: SystemColors.hpGreen.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Checked Box (Tap to uncheck/reopen with tactile click)
              InkWell(
                onTap: () {
                  try {
                    HapticFeedback.selectionClick();
                  } catch (_) {}
                  widget.state.toggleQuestComplete(quest.id, date: date);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: SystemColors.hpGreen,
                  ),
                  child: const Center(
                    child: Icon(Icons.check, color: Colors.black, size: 16),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Title with Strikethrough
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest.title,
                      style: GoogleFonts.orbitron(
                        color: Colors.white54,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: SystemColors.hpGreen.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      'Executed • ${quest.target} ${quest.unit} • +${quest.expReward} EXP',
                      style: GoogleFonts.rajdhani(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Cleared Badge
              InkWell(
                onTap: widget.onAttributeTap,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: SystemColors.hpGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: SystemColors.hpGreen.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '[ CLEARED • +1 ${quest.statReward.code} ]',
                        style: GoogleFonts.orbitron(
                          color: SystemColors.hpGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_drop_down, color: SystemColors.hpGreen, size: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Day Tracker Grid (Heatmap Matrix below habit)
          HabitDayTrackerGrid(
            questId: quest.id,
            state: widget.state,
            activeColor: SystemColors.hpGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressButtons(BuildContext context, Quest quest, DateTime date) {
    if (quest.target >= 100) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildQuickAddBtn(quest, 10, '+10', date),
          const SizedBox(width: 8),
          _buildQuickAddBtn(quest, 25, '+25', date),
          const SizedBox(width: 8),
          _buildQuickAddBtn(quest, quest.target - quest.current, 'EXECUTE', date, isMax: true),
        ],
      );
    } else if (quest.target >= 10) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildQuickAddBtn(quest, 1, '+1', date),
          const SizedBox(width: 8),
          _buildQuickAddBtn(quest, 5, '+5', date),
          const SizedBox(width: 8),
          _buildQuickAddBtn(quest, quest.target - quest.current, 'EXECUTE', date, isMax: true),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildQuickAddBtn(quest, 1, '+1', date),
          const SizedBox(width: 8),
          _buildQuickAddBtn(quest, quest.target - quest.current, 'EXECUTE', date, isMax: true),
        ],
      );
    }
  }

  Widget _buildQuickAddBtn(
    Quest quest,
    int amount,
    String label,
    DateTime date, {
    bool isMax = false,
  }) {
    return InkWell(
      onTap: () {
        if (isMax || (quest.current + amount >= quest.target)) {
          _triggerDeadlyExecution(
            onExecute: () => widget.state.incrementQuestProgress(quest.id, amount, date: date),
          );
        } else {
          try {
            HapticFeedback.selectionClick();
          } catch (_) {}
          widget.state.incrementQuestProgress(quest.id, amount, date: date);
        }
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isMax ? SystemColors.cyanGlow : SystemColors.cyanGlow.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isMax ? SystemColors.cyanGlow : SystemColors.cyanGlow.withValues(alpha: 0.8),
            width: 0.8,
          ),
          boxShadow: isMax
              ? [
                  BoxShadow(
                    color: SystemColors.cyanGlow.withValues(alpha: 0.3),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.orbitron(
            color: isMax ? Colors.black : SystemColors.cyanGlow,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Custom Animated Painter for the Deadly Diagonal Blade Slash & Shockwave Sparks
class DeadlySlashPainter extends CustomPainter {
  final double progress;
  final Color slashColor;
  final Color glowColor;

  DeadlySlashPainter({
    required this.progress,
    required this.slashColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final start = Offset(0, size.height * 0.15);
    final end = Offset(size.width, size.height * 0.85);

    final currentX = start.dx + (end.dx - start.dx) * progress;
    final currentY = start.dy + (end.dy - start.dy) * progress;
    final currentPos = Offset(currentX, currentY);

    // 1. Slash Glow Aura Trail
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: (1.0 - progress) * 0.8)
      ..strokeWidth = 14.0 * (1.0 - progress)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawLine(start, currentPos, glowPaint);

    // 2. Razor Sharp Crimson / Cyan Slash Line
    final slashPaint = Paint()
      ..color = slashColor.withValues(alpha: (1.0 - progress * 0.5))
      ..strokeWidth = 3.5 * (1.0 - progress * 0.3)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, currentPos, slashPaint);

    // 3. Hot White Core Line
    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: (1.0 - progress * 0.8))
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, currentPos, corePaint);

    // 4. Explosive Kinetic Sparks around impact point
    final rand = Random(42);
    final sparkPaint = Paint()
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final angle = rand.nextDouble() * 2 * pi;
      final distance = (rand.nextDouble() * 24 + 6) * progress;
      final sparkPos = Offset(
        currentPos.dx + cos(angle) * distance,
        currentPos.dy + sin(angle) * distance,
      );
      final sparkRadius = (rand.nextDouble() * 2.5 + 1.0) * (1.0 - progress);

      sparkPaint.color = (i % 2 == 0 ? slashColor : Colors.white)
          .withValues(alpha: (1.0 - progress));

      canvas.drawCircle(sparkPos, sparkRadius, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant DeadlySlashPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
