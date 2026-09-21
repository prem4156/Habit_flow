import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/system_state.dart';
import '../theme/system_theme.dart';
import '../widgets/system_window.dart';

/// Weekly Performance Report — a full-screen analysis of the hunter's
/// last 7 days, computed entirely from existing [SystemState] data.
class WeeklyReportScreen extends StatefulWidget {
  final SystemState state;
  const WeeklyReportScreen({super.key, required this.state});

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  /// Offset in weeks from the current week (0 = this week, -1 = last week, etc.)
  int _weekOffset = 0;

  SystemState get state => widget.state;

  // ── Helpers ──────────────────────────────────────────────────────────

  /// Returns the 7 dates for a week defined by [offset] from today.
  List<DateTime> _weekDates(int offset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfThisWeek = today.subtract(const Duration(days: 6)); // last 7 days
    final start = startOfThisWeek.add(Duration(days: offset * 7));
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  // ── Computed metrics ─────────────────────────────────────────────────

  _WeekMetrics _computeMetrics(int offset) {
    final dates = _weekDates(offset);
    int totalSlots = 0;
    int completedSlots = 0;
    final List<double> dailyRatios = [];
    int xpEarned = 0;

    // Per-quest completion counts
    final Map<String, int> questCompletions = {};

    for (final date in dates) {
      final quests = state.getQuestsForDate(date);
      final total = state.getDateTotalCount(date);
      final completed = state.getDateCompletedCount(date);
      totalSlots += total;
      completedSlots += completed;
      dailyRatios.add(state.getDateCompletionRatio(date));

      for (final q in quests) {
        if (state.isQuestCompletedOnDate(q.id, date)) {
          questCompletions[q.id] = (questCompletions[q.id] ?? 0) + 1;
          xpEarned += q.expReward;
        }
      }
    }

    final overallRatio = totalSlots > 0 ? completedSlots / totalSlots : 0.0;
    final missedSlots = totalSlots - completedSlots;

    // Best & worst performing quests
    String? bestQuestId;
    String? worstQuestId;
    int bestCount = -1;
    int worstCount = 999999;

    final allQuests = state.allTemplateQuests;
    for (final q in allQuests) {
      final count = questCompletions[q.id] ?? 0;
      if (count > bestCount) {
        bestCount = count;
        bestQuestId = q.id;
      }
      if (count < worstCount) {
        worstCount = count;
        worstQuestId = q.id;
      }
    }

    return _WeekMetrics(
      dates: dates,
      totalSlots: totalSlots,
      completedSlots: completedSlots,
      missedSlots: missedSlots,
      overallRatio: overallRatio,
      dailyRatios: dailyRatios,
      xpEarned: xpEarned,
      questCompletions: questCompletions,
      bestQuestId: bestQuestId,
      worstQuestId: worstQuestId,
      bestCount: bestCount,
      worstCount: worstCount,
    );
  }

  String _questTitle(String? id) {
    if (id == null) return '—';
    final q = state.allTemplateQuests.cast<dynamic>().firstWhere(
          (q) => q.id == id,
          orElse: () => null,
        );
    return q?.title ?? '—';
  }

  String _formatDateRange(List<DateTime> dates) {
    if (dates.isEmpty) return '';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final first = dates.first;
    final last = dates.last;
    if (first.month == last.month) {
      return '${months[first.month - 1]} ${first.day} – ${last.day}, ${last.year}';
    }
    return '${months[first.month - 1]} ${first.day} – ${months[last.month - 1]} ${last.day}, ${last.year}';
  }

  // ── Insight generator ────────────────────────────────────────────────

  String _generateInsight(_WeekMetrics current, _WeekMetrics previous) {
    final insights = <String>[];

    // Comparison insight
    final currentPct = (current.overallRatio * 100).round();
    final previousPct = (previous.overallRatio * 100).round();
    final delta = currentPct - previousPct;
    if (delta > 0) {
      insights.add('You improved $delta% compared with last week. Keep pushing!');
    } else if (delta < 0) {
      insights.add('You dropped ${delta.abs()}% compared with last week. Time to refocus.');
    } else if (currentPct > 0) {
      insights.add('Holding steady at $currentPct% — consistency is your weapon.');
    }

    // Best habit insight
    if (current.bestQuestId != null && current.bestCount > 0) {
      final title = _questTitle(current.bestQuestId);
      if (current.bestCount >= 7) {
        insights.add('$title was completed every single day. Legendary discipline.');
      } else if (current.bestCount >= 5) {
        insights.add('$title was your most consistent habit this week.');
      }
    }

    // Worst habit insight
    if (current.worstQuestId != null && current.worstCount == 0 && state.allTemplateQuests.length > 1) {
      final title = _questTitle(current.worstQuestId);
      insights.add('$title was skipped all week — consider prioritizing it.');
    }

    // Streak insight
    if (state.consecutivePerfectDays >= 7) {
      insights.add('${state.consecutivePerfectDays}-day streak active. The System acknowledges your resolve.');
    }

    if (insights.isEmpty) {
      insights.add('Complete your first quest to start generating insights.');
    }

    return insights.join('\n');
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = SystemTheme.isDark(context);
    final accent = SystemTheme.getPrimaryAccent(context);
    final metrics = _computeMetrics(_weekOffset);
    final prevMetrics = _computeMetrics(_weekOffset - 1);
    final insight = _generateInsight(metrics, prevMetrics);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isFutureWeek = metrics.dates.last.isAfter(today);

    return Scaffold(
      backgroundColor: SystemTheme.getBackground(context),
      appBar: AppBar(
        backgroundColor: SystemTheme.getPanelBg(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: accent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'WEEKLY FIELD REPORT',
          style: GoogleFonts.orbitron(
            color: accent,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: 0.8),
                  accent.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Grid background
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.05 : 0.03,
              child: CustomPaint(
                painter: _GridPainter(isDark: isDark),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Week Navigator ──
                _buildWeekNavigator(context, metrics, isFutureWeek),
                const SizedBox(height: 8),

                // ── 1. Overall Completion Ring ──
                _buildCompletionRing(context, metrics),

                // ── 2. Completed vs Missed ──
                _buildCompletedVsMissed(context, metrics),

                // ── 3. 7-Day Activity Chart ──
                _buildActivityChart(context, metrics),

                // ── 4. XP & Streak ──
                _buildXpAndStreak(context, metrics),

                // ── 5. Best & Needs Attention ──
                _buildBestAndWorst(context, metrics),

                // ── 6. Previous Week Comparison ──
                _buildComparison(context, metrics, prevMetrics),

                // ── 7. Insight ──
                _buildInsightSection(context, insight),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Widgets ──────────────────────────────────────────────────────────

  Widget _buildWeekNavigator(BuildContext context, _WeekMetrics m, bool isFutureWeek) {
    final accent = SystemTheme.getPrimaryAccent(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: accent),
          onPressed: () => setState(() => _weekOffset--),
        ),
        Column(
          children: [
            Text(
              _formatDateRange(m.dates),
              style: GoogleFonts.orbitron(
                color: SystemTheme.getTextPrimary(context),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            if (_weekOffset == 0)
              Text(
                'CURRENT WEEK',
                style: GoogleFonts.orbitron(
                  color: accent,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.chevron_right,
            color: isFutureWeek
                ? SystemTheme.getTextMuted(context)
                : accent,
          ),
          onPressed: isFutureWeek ? null : () => setState(() => _weekOffset++),
        ),
      ],
    );
  }

  Widget _buildCompletionRing(BuildContext context, _WeekMetrics m) {
    final isDark = SystemTheme.isDark(context);
    final accent = SystemTheme.getPrimaryAccent(context);
    final pct = (m.overallRatio * 100).round();

    return SystemWindow(
      title: 'Mission Completion',
      child: Center(
        child: SizedBox(
          width: 180,
          height: 180,
          child: CustomPaint(
            painter: _RingPainter(
              ratio: m.overallRatio,
              accent: accent,
              isDark: isDark,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$pct%',
                    style: GoogleFonts.orbitron(
                      color: SystemTheme.getTextPrimary(context),
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          color: accent.withValues(alpha: 0.5),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'WEEKLY RATE',
                    style: GoogleFonts.orbitron(
                      color: SystemTheme.getTextSecondary(context),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedVsMissed(BuildContext context, _WeekMetrics m) {
    final isDark = SystemTheme.isDark(context);
    return SystemWindow(
      title: 'Completed vs Missed',
      child: Row(
        children: [
          Expanded(
            child: _statCard(
              context,
              icon: Icons.check_circle_outline,
              label: 'COMPLETED',
              value: '${m.completedSlots}',
              color: isDark ? SystemColors.cyanGlow : SystemColors.lightCyanGlow,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statCard(
              context,
              icon: Icons.cancel_outlined,
              label: 'MISSED',
              value: '${m.missedSlots}',
              color: SystemColors.crimsonGlow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = SystemTheme.isDark(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.3 : 0.5), width: isDark ? 1.0 : 1.2),
        boxShadow: [
          if (!isDark)
            const BoxShadow(
              color: Color(0x080F172A),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.orbitron(
              color: SystemTheme.getTextPrimary(context),
              fontSize: 28,
              fontWeight: FontWeight.w900,
              shadows: isDark
                  ? [
                      Shadow(color: color.withValues(alpha: 0.5), blurRadius: 10),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart(BuildContext context, _WeekMetrics m) {
    final isDark = SystemTheme.isDark(context);
    final accent = SystemTheme.getPrimaryAccent(context);
    final dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    return SystemWindow(
      title: '7-Day Activity',
      trailing: Text(
        'DAILY COMPLETION',
        style: GoogleFonts.orbitron(
          color: SystemTheme.getTextSecondary(context),
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
      child: SizedBox(
        height: 160,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (i) {
            final ratio = m.dailyRatios[i];
            final pct = (ratio * 100).round();
            final weekday = m.dates[i].weekday;
            final label = dayNames[weekday - 1];
            final now = DateTime.now();
            final isToday = m.dates[i].year == now.year &&
                m.dates[i].month == now.month &&
                m.dates[i].day == now.day;

            Color barColor;
            if (ratio >= 1.0) {
              barColor = accent;
            } else if (ratio >= 0.5) {
              barColor = isDark ? SystemColors.blueGlow : SystemColors.lightBlueGlow;
            } else if (ratio > 0) {
              barColor = SystemColors.goldAccent;
            } else {
              barColor = SystemTheme.getTextMuted(context).withValues(alpha: 0.3);
            }

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$pct%',
                      style: GoogleFonts.orbitron(
                        color: ratio >= 1.0
                            ? accent
                            : SystemTheme.getTextSecondary(context),
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: max(0.04, ratio),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  barColor,
                                  barColor.withValues(alpha: 0.6),
                                ],
                              ),
                              boxShadow: ratio > 0
                                  ? [
                                      BoxShadow(
                                        color: barColor.withValues(alpha: 0.4),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: GoogleFonts.orbitron(
                        color: isToday
                            ? accent
                            : SystemTheme.getTextSecondary(context),
                        fontSize: 8,
                        fontWeight: isToday ? FontWeight.w900 : FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildXpAndStreak(BuildContext context, _WeekMetrics m) {
    return SystemWindow(
      title: 'Power Gains',
      child: Row(
        children: [
          Expanded(
            child: _statCard(
              context,
              icon: Icons.flash_on,
              label: 'XP EARNED',
              value: '${m.xpEarned}',
              color: SystemTheme.getPurpleAccent(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statCard(
              context,
              icon: Icons.local_fire_department,
              label: 'CURRENT STREAK',
              value: '${state.consecutivePerfectDays}',
              color: SystemTheme.getGoldAccent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestAndWorst(BuildContext context, _WeekMetrics m) {
    final isDark = SystemTheme.isDark(context);
    final accent = SystemTheme.getPrimaryAccent(context);

    return SystemWindow(
      title: 'Habit Analysis',
      child: Column(
        children: [
          _habitAnalysisRow(
            context,
            emoji: '🏆',
            label: 'BEST PERFORMING',
            questTitle: _questTitle(m.bestQuestId),
            count: m.bestCount,
            color: isDark ? SystemColors.cyanGlow : accent,
          ),
          const SizedBox(height: 10),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _habitAnalysisRow(
            context,
            emoji: '⚠️',
            label: 'NEEDS ATTENTION',
            questTitle: _questTitle(m.worstQuestId),
            count: m.worstCount,
            color: SystemTheme.getCrimsonAccent(context),
          ),
        ],
      ),
    );
  }

  Widget _habitAnalysisRow(
    BuildContext context, {
    required String emoji,
    required String label,
    required String questTitle,
    required int count,
    required Color color,
  }) {
    final isDark = SystemTheme.isDark(context);
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.1 : 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.orbitron(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                questTitle,
                style: GoogleFonts.rajdhani(
                  color: SystemTheme.getTextPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Text(
            '$count/7',
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparison(BuildContext context, _WeekMetrics current, _WeekMetrics prev) {
    final isDark = SystemTheme.isDark(context);
    final accent = SystemTheme.getPrimaryAccent(context);
    final purple = SystemTheme.getPurpleAccent(context);
    final currentPct = (current.overallRatio * 100).round();
    final prevPct = (prev.overallRatio * 100).round();
    final delta = currentPct - prevPct;

    final isUp = delta > 0;
    final isFlat = delta == 0;
    final Color deltaColor;
    final IconData deltaIcon;

    if (isFlat) {
      deltaColor = SystemTheme.getTextSecondary(context);
      deltaIcon = Icons.remove;
    } else if (isUp) {
      deltaColor = SystemTheme.getGreenAccent(context);
      deltaIcon = Icons.arrow_upward;
    } else {
      deltaColor = SystemTheme.getCrimsonAccent(context);
      deltaIcon = Icons.arrow_downward;
    }

    return SystemWindow(
      title: 'Previous Week Comparison',
      borderColor: purple,
      titleColor: purple,
      child: Row(
        children: [
          // Previous week
          Expanded(
            child: Column(
              children: [
                Text(
                  'PREV WEEK',
                  style: GoogleFonts.orbitron(
                    color: SystemTheme.getTextMuted(context),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$prevPct%',
                  style: GoogleFonts.orbitron(
                    color: SystemTheme.getTextSecondary(context),
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          // Delta indicator
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: deltaColor.withValues(alpha: isDark ? 0.15 : 0.1),
              border: Border.all(color: deltaColor.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: deltaColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(deltaIcon, color: deltaColor, size: 24),
          ),
          // Current week
          Expanded(
            child: Column(
              children: [
                Text(
                  'THIS WEEK',
                  style: GoogleFonts.orbitron(
                    color: accent,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$currentPct%',
                  style: GoogleFonts.orbitron(
                    color: SystemTheme.getTextPrimary(context),
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    shadows: [
                      Shadow(color: accent.withValues(alpha: 0.4), blurRadius: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightSection(BuildContext context, String insight) {
    final isDark = SystemTheme.isDark(context);
    final purple = SystemTheme.getPurpleAccent(context);

    return SystemWindow(
      title: 'System Insight',
      borderColor: purple,
      titleColor: purple,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: purple.withValues(alpha: isDark ? 0.06 : 0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: purple.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.auto_awesome,
              color: purple,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                insight,
                style: GoogleFonts.rajdhani(
                  color: SystemTheme.getTextPrimary(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data class ───────────────────────────────────────────────────────────

class _WeekMetrics {
  final List<DateTime> dates;
  final int totalSlots;
  final int completedSlots;
  final int missedSlots;
  final double overallRatio;
  final List<double> dailyRatios;
  final int xpEarned;
  final Map<String, int> questCompletions;
  final String? bestQuestId;
  final String? worstQuestId;
  final int bestCount;
  final int worstCount;

  const _WeekMetrics({
    required this.dates,
    required this.totalSlots,
    required this.completedSlots,
    required this.missedSlots,
    required this.overallRatio,
    required this.dailyRatios,
    required this.xpEarned,
    required this.questCompletions,
    required this.bestQuestId,
    required this.worstQuestId,
    required this.bestCount,
    required this.worstCount,
  });
}

// ── Custom painters ──────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double ratio;
  final Color accent;
  final bool isDark;

  _RingPainter({
    required this.ratio,
    required this.accent,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;
    const strokeWidth = 10.0;

    // Background track
    final bgPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.06)
          : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Foreground arc
    if (ratio > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final sweepAngle = 2 * pi * ratio.clamp(0.0, 1.0);
      final arcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: -pi / 2,
          endAngle: -pi / 2 + sweepAngle,
          colors: [
            accent,
            accent.withValues(alpha: 0.6),
            accent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect);

      canvas.drawArc(
        rect,
        -pi / 2,
        sweepAngle,
        false,
        arcPaint,
      );

      // Glow effect
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 6
        ..strokeCap = StrokeCap.round
        ..color = accent.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawArc(rect, -pi / 2, sweepAngle, false, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.ratio != ratio || old.accent != accent || old.isDark != isDark;
}

class _GridPainter extends CustomPainter {
  final bool isDark;
  _GridPainter({this.isDark = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? SystemColors.cyanGlow : SystemColors.lightCyanGlow
      ..strokeWidth = 0.5;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) => old.isDark != isDark;
}
