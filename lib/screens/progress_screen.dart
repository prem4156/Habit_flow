import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/achievement_model.dart';
import '../models/hunter_model.dart';
import '../services/system_state.dart';
import '../theme/system_theme.dart';
import '../widgets/system_window.dart';
import 'weekly_report_screen.dart';

class ProgressScreen extends StatelessWidget {
  final SystemState state;
  const ProgressScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final profile = state.profile;
    final primaryAccent = SystemTheme.getPrimaryAccent(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screen Title
          Row(
            children: [
              Icon(Icons.trending_up, color: primaryAccent, size: 22),
              const SizedBox(width: 10),
              Text(
                'PROGRESS REPORT',
                style: GoogleFonts.orbitron(
                  color: primaryAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'System Status • Real-Time Character Analysis',
            style: GoogleFonts.rajdhani(
              color: SystemTheme.getTextSecondary(context),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // WEEKLY REPORT ENTRY POINT
          _buildWeeklyReportButton(context),
          const SizedBox(height: 8),

          // 1. LEVEL PROGRESS
          _buildLevelSection(context, profile),

          // 2. STREAK RECORD
          _buildStreakSection(context),

          // 3. CHARACTER DEVELOPMENT
          _buildCharacterDevelopment(context, profile),

          // 4. ACHIEVEMENTS
          _buildAchievementsSection(context),

          // 5. WEEKLY PERFORMANCE
          _buildWeeklyPerformance(context),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWeeklyReportButton(BuildContext context) {
    final isDark = SystemTheme.isDark(context);
    final accent = SystemTheme.getPurpleAccent(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WeeklyReportScreen(state: state),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: isDark ? 0.08 : 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accent.withValues(alpha: 0.5), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: isDark ? 0.2 : 0.12),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.assessment, color: accent, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WEEKLY FIELD REPORT',
                    style: GoogleFonts.orbitron(
                      color: accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'View detailed weekly mission analysis',
                    style: GoogleFonts.rajdhani(
                      color: SystemTheme.getTextSecondary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: accent, size: 22),
          ],
        ),
      ),
    );
  }

  // ==============================
  // 1. LEVEL PROGRESS
  // ==============================
  Widget _buildLevelSection(BuildContext context, HunterProfile profile) {
    final isDark = SystemTheme.isDark(context);
    final primaryAccent = SystemTheme.getPrimaryAccent(context);
    final expPercent = profile.maxExp > 0
        ? (profile.exp / profile.maxExp).clamp(0.0, 1.0)
        : 0.0;
    final percentText = (expPercent * 100).toStringAsFixed(1);

    return SystemWindow(
      title: 'Level & Experience',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: primaryAccent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: primaryAccent, width: 0.8),
        ),
        child: Text(
          profile.rank.label,
          style: GoogleFonts.orbitron(
            color: primaryAccent,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'LEVEL',
                style: GoogleFonts.orbitron(
                  color: SystemTheme.getTextSecondary(context),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${profile.level}',
                style: GoogleFonts.orbitron(
                  color: primaryAccent,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  shadows: [
                    Shadow(
                      color: primaryAccent.withValues(alpha: 0.5),
                      blurRadius: 15,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // XP Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: SystemTheme.getProgressTrack(context),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isDark
                          ? primaryAccent.withValues(alpha: 0.3)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: expPercent,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: [
                          primaryAccent.withValues(alpha: 0.85),
                          isDark ? SystemColors.blueGlow : const Color(0xFF0284C7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryAccent.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                  child: Center(
                    child: Text(
                      '${profile.exp} / ${profile.maxExp} XP',
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          const Shadow(color: Colors.black54, blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$percentText% to Level ${profile.level + 1}',
              style: GoogleFonts.rajdhani(
                color: SystemTheme.getTextSecondary(context),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================
  // 2. STREAK RECORD
  // ==============================
  Widget _buildStreakSection(BuildContext context) {
    return SystemWindow(
      title: 'Streak Record',
      child: Row(
        children: [
          Expanded(
            child: _buildStreakCard(
              context,
              '🔥',
              'CURRENT STREAK',
              '${state.consecutivePerfectDays}',
              'DAYS',
              SystemTheme.getPrimaryAccent(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStreakCard(
              context,
              '🏆',
              'BEST STREAK',
              '${state.bestStreak}',
              'DAYS',
              SystemTheme.getGoldAccent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(
      BuildContext context, String emoji, String label, String value, String unit, Color color) {
    final isDark = SystemTheme.isDark(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.06 : 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.3 : 0.4)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.orbitron(
              color: SystemTheme.getTextPrimary(context),
              fontSize: 32,
              fontWeight: FontWeight.w900,
              shadows: isDark
                  ? [
                      Shadow(color: color.withValues(alpha: 0.5), blurRadius: 10),
                    ]
                  : null,
            ),
          ),
          Text(
            unit,
            style: GoogleFonts.orbitron(
              color: SystemTheme.getTextSecondary(context),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================
  // 3. CHARACTER DEVELOPMENT
  // ==============================
  Widget _buildCharacterDevelopment(BuildContext context, HunterProfile profile) {
    final stats = [
      _StatEntry('STR', 'Strength', profile.stats.strength, SystemTheme.getCrimsonAccent(context)),
      _StatEntry('AGI', 'Agility', profile.stats.agility, SystemTheme.getPrimaryAccent(context)),
      _StatEntry('VIT', 'Vitality', profile.stats.vitality, SystemTheme.getGreenAccent(context)),
      _StatEntry('INT', 'Intelligence', profile.stats.intelligence, SystemTheme.getPurpleAccent(context)),
      _StatEntry('PER', 'Perception', profile.stats.perception, SystemTheme.getGoldAccent(context)),
    ];

    return SystemWindow(
      title: 'Character Development',
      trailing: Text(
        'TOTAL: ${stats.fold<int>(0, (s, e) => s + e.value)}',
        style: GoogleFonts.orbitron(
          color: SystemTheme.getTextSecondary(context),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Column(
        children: stats.map((s) => _buildStatBar(context, s)).toList(),
      ),
    );
  }

  Widget _buildStatBar(BuildContext context, _StatEntry stat) {
    final isDark = SystemTheme.isDark(context);
    const maxVal = 100.0;
    final ratio = (stat.value / maxVal).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              stat.code,
              style: GoogleFonts.orbitron(
                color: stat.color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: SystemTheme.getProgressTrack(context),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: isDark
                          ? stat.color.withValues(alpha: 0.2)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: LinearGradient(
                        colors: [
                          stat.color.withValues(alpha: 0.75),
                          stat.color,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: stat.color.withValues(alpha: isDark ? 0.3 : 0.15),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 30,
            child: Text(
              '${stat.value}',
              textAlign: TextAlign.right,
              style: GoogleFonts.orbitron(
                color: SystemTheme.getTextPrimary(context),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================
  // 4. ACHIEVEMENTS
  // ==============================
  Widget _buildAchievementsSection(BuildContext context) {
    final unlockedCount =
        state.achievements.where((a) => a.isUnlocked).length;
    final purpleAccent = SystemTheme.getPurpleAccent(context);

    return SystemWindow(
      title: 'Achievements',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: purpleAccent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: purpleAccent, width: 0.8),
        ),
        child: Text(
          '$unlockedCount/${state.achievements.length}',
          style: GoogleFonts.orbitron(
            color: purpleAccent,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
      child: Column(
        children: state.achievements
            .map((a) => _buildAchievementRow(context, a))
            .toList(),
      ),
    );
  }

  Widget _buildAchievementRow(BuildContext context, Achievement achievement) {
    final isDark = SystemTheme.isDark(context);
    Color tierColor;
    switch (achievement.tier) {
      case AchievementTier.bronze:
        tierColor = isDark ? const Color(0xFFCD7F32) : const Color(0xFFB45309);
        break;
      case AchievementTier.silver:
        tierColor = isDark ? const Color(0xFFC0C0C0) : const Color(0xFF64748B);
        break;
      case AchievementTier.gold:
        tierColor = SystemTheme.getGoldAccent(context);
        break;
      case AchievementTier.legendary:
        tierColor = SystemTheme.getPurpleAccent(context);
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: achievement.isUnlocked
              ? tierColor.withValues(alpha: isDark ? 0.08 : 0.12)
              : (isDark ? Colors.black38 : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: achievement.isUnlocked
                ? tierColor.withValues(alpha: isDark ? 0.5 : 0.6)
                : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0)),
            width: achievement.isUnlocked ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: achievement.isUnlocked
                    ? tierColor.withValues(alpha: isDark ? 0.2 : 0.15)
                    : (isDark ? Colors.black45 : const Color(0xFFE2E8F0)),
                border: Border.all(
                  color: achievement.isUnlocked
                      ? tierColor
                      : (isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  achievement.isUnlocked ? achievement.badge : '?',
                  style: TextStyle(
                    fontSize: achievement.isUnlocked ? 18 : 16,
                    color: achievement.isUnlocked
                        ? null
                        : (isDark ? Colors.white24 : const Color(0xFF94A3B8)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: GoogleFonts.orbitron(
                      color: achievement.isUnlocked
                          ? tierColor
                          : SystemTheme.getTextMuted(context),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    achievement.description,
                    style: GoogleFonts.rajdhani(
                      color: achievement.isUnlocked
                          ? SystemTheme.getTextSecondary(context)
                          : SystemTheme.getTextMuted(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (!achievement.isUnlocked &&
                      achievement.maxProgress > 1) ...[
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: achievement.progress,
                        minHeight: 4,
                        backgroundColor: SystemTheme.getProgressTrack(context),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            tierColor.withValues(alpha: isDark ? 0.6 : 0.8)),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${achievement.currentProgress} / ${achievement.maxProgress}',
                      style: GoogleFonts.orbitron(
                        color: SystemTheme.getTextMuted(context),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              achievement.isUnlocked
                  ? Icons.check_circle
                  : Icons.lock_outline,
              color: achievement.isUnlocked
                  ? tierColor
                  : (isDark ? Colors.white24 : const Color(0xFF94A3B8)),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ==============================
  // 5. WEEKLY PERFORMANCE
  // ==============================
  Widget _buildWeeklyPerformance(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    // Build last 7 days, most recent first
    final days = <_DayPerf>[];
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final ratio = state.getDateCompletionRatio(date);
      final weekday = date.weekday; // 1=Monday
      final dayLabel = dayNames[weekday - 1];
      final isToday = i == 0;
      days.add(_DayPerf(dayLabel, ratio, isToday, date));
    }

    return SystemWindow(
      title: 'Weekly Performance',
      trailing: Text(
        'LAST 7 DAYS',
        style: GoogleFonts.orbitron(
          color: SystemTheme.getTextSecondary(context),
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
      child: Column(
        children: days.map((d) => _buildDayRow(context, d)).toList(),
      ),
    );
  }

  Widget _buildDayRow(BuildContext context, _DayPerf day) {
    final isDark = SystemTheme.isDark(context);
    final primaryAccent = SystemTheme.getPrimaryAccent(context);
    final pctText = '${(day.ratio * 100).toInt()}%';
    final barColor = day.ratio >= 1.0
        ? primaryAccent
        : day.ratio >= 0.5
            ? (isDark ? SystemColors.blueGlow : const Color(0xFF0284C7))
            : day.ratio > 0
                ? SystemTheme.getGoldAccent(context)
                : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFCBD5E1));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              day.label,
              style: GoogleFonts.orbitron(
                color: day.isToday
                    ? primaryAccent
                    : SystemTheme.getTextSecondary(context),
                fontSize: 10,
                fontWeight:
                    day.isToday ? FontWeight.w900 : FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: SystemTheme.getProgressTrack(context),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: day.ratio,
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: barColor,
                      boxShadow: day.ratio > 0
                          ? [
                              BoxShadow(
                                color: barColor.withValues(alpha: isDark ? 0.3 : 0.15),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 36,
            child: Text(
              pctText,
              textAlign: TextAlign.right,
              style: GoogleFonts.orbitron(
                color: day.ratio >= 1.0
                    ? primaryAccent
                    : SystemTheme.getTextSecondary(context),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (day.ratio >= 1.0) ...[
            const SizedBox(width: 4),
            Icon(Icons.check_circle,
                color: primaryAccent, size: 14),
          ],
        ],
      ),
    );
  }
}

// Helper data classes
class _StatEntry {
  final String code;
  final String label;
  final int value;
  final Color color;
  const _StatEntry(this.code, this.label, this.value, this.color);
}

class _DayPerf {
  final String label;
  final double ratio;
  final bool isToday;
  final DateTime date;
  const _DayPerf(this.label, this.ratio, this.isToday, this.date);
}
