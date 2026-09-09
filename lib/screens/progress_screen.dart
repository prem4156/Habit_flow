import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/achievement_model.dart';
import '../models/hunter_model.dart';
import '../services/system_state.dart';
import '../theme/system_theme.dart';
import '../widgets/system_window.dart';

class ProgressScreen extends StatelessWidget {
  final SystemState state;
  const ProgressScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final profile = state.profile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screen Title
          Row(
            children: [
              const Icon(Icons.trending_up, color: SystemColors.cyanGlow, size: 22),
              const SizedBox(width: 10),
              Text(
                'PROGRESS REPORT',
                style: GoogleFonts.orbitron(
                  color: SystemColors.cyanGlow,
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
              color: SystemColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // 1. LEVEL PROGRESS
          _buildLevelSection(profile),

          // 2. STREAK RECORD
          _buildStreakSection(),

          // 3. CHARACTER DEVELOPMENT
          _buildCharacterDevelopment(profile),

          // 4. ACHIEVEMENTS
          _buildAchievementsSection(),

          // 5. WEEKLY PERFORMANCE
          _buildWeeklyPerformance(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ==============================
  // 1. LEVEL PROGRESS
  // ==============================
  Widget _buildLevelSection(HunterProfile profile) {
    final expPercent = profile.maxExp > 0
        ? (profile.exp / profile.maxExp).clamp(0.0, 1.0)
        : 0.0;
    final percentText = (expPercent * 100).toStringAsFixed(1);

    return SystemWindow(
      title: 'Level & Experience',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: SystemColors.cyanGlow.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: SystemColors.cyanGlow, width: 0.8),
        ),
        child: Text(
          profile.rank.label,
          style: GoogleFonts.orbitron(
            color: SystemColors.cyanGlow,
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
                  color: SystemColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${profile.level}',
                style: GoogleFonts.orbitron(
                  color: SystemColors.cyanGlow,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  shadows: [
                    Shadow(
                      color: SystemColors.cyanGlow.withValues(alpha: 0.5),
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
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: SystemColors.cyanGlow.withValues(alpha: 0.3)),
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
                          SystemColors.cyanGlow.withValues(alpha: 0.8),
                          SystemColors.blueGlow,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              SystemColors.cyanGlow.withValues(alpha: 0.4),
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
                          const Shadow(
                              color: Colors.black, blurRadius: 4),
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
                color: SystemColors.textSecondary,
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
  Widget _buildStreakSection() {
    return SystemWindow(
      title: 'Streak Record',
      child: Row(
        children: [
          Expanded(
            child: _buildStreakCard(
              '🔥',
              'CURRENT STREAK',
              '${state.consecutivePerfectDays}',
              'DAYS',
              SystemColors.cyanGlow,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStreakCard(
              '🏆',
              'BEST STREAK',
              '${state.bestStreak}',
              'DAYS',
              SystemColors.goldAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(
      String emoji, String label, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(color: color.withValues(alpha: 0.5), blurRadius: 10),
              ],
            ),
          ),
          Text(
            unit,
            style: GoogleFonts.orbitron(
              color: SystemColors.textSecondary,
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
  Widget _buildCharacterDevelopment(HunterProfile profile) {
    final stats = [
      _StatEntry('STR', 'Strength', profile.stats.strength, SystemColors.crimsonGlow),
      _StatEntry('AGI', 'Agility', profile.stats.agility, const Color(0xFF00E5FF)),
      _StatEntry('VIT', 'Vitality', profile.stats.vitality, const Color(0xFF4CAF50)),
      _StatEntry('INT', 'Intelligence', profile.stats.intelligence, SystemColors.purpleShadow),
      _StatEntry('PER', 'Perception', profile.stats.perception, SystemColors.goldAccent),
    ];

    return SystemWindow(
      title: 'Character Development',
      trailing: Text(
        'TOTAL: ${stats.fold<int>(0, (s, e) => s + e.value)}',
        style: GoogleFonts.orbitron(
          color: SystemColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Column(
        children: stats.map((s) => _buildStatBar(s)).toList(),
      ),
    );
  }

  Widget _buildStatBar(_StatEntry stat) {
    final maxVal = 100.0;
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
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                        color: stat.color.withValues(alpha: 0.2)),
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
                          stat.color.withValues(alpha: 0.7),
                          stat.color,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: stat.color.withValues(alpha: 0.3),
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
                color: Colors.white,
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
  Widget _buildAchievementsSection() {
    final unlockedCount =
        state.achievements.where((a) => a.isUnlocked).length;

    return SystemWindow(
      title: 'Achievements',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: SystemColors.purpleShadow.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
          border:
              Border.all(color: SystemColors.purpleShadow, width: 0.8),
        ),
        child: Text(
          '$unlockedCount/${state.achievements.length}',
          style: GoogleFonts.orbitron(
            color: SystemColors.purpleShadow,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
      child: Column(
        children: state.achievements
            .map((a) => _buildAchievementRow(a))
            .toList(),
      ),
    );
  }

  Widget _buildAchievementRow(Achievement achievement) {
    Color tierColor;
    switch (achievement.tier) {
      case AchievementTier.bronze:
        tierColor = const Color(0xFFCD7F32);
      case AchievementTier.silver:
        tierColor = const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        tierColor = SystemColors.goldAccent;
      case AchievementTier.legendary:
        tierColor = SystemColors.purpleShadow;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: achievement.isUnlocked
              ? tierColor.withValues(alpha: 0.08)
              : Colors.black38,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: achievement.isUnlocked
                ? tierColor.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
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
                    ? tierColor.withValues(alpha: 0.2)
                    : Colors.black45,
                border: Border.all(
                  color:
                      achievement.isUnlocked ? tierColor : Colors.white24,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  achievement.isUnlocked ? achievement.badge : '?',
                  style: TextStyle(
                    fontSize: achievement.isUnlocked ? 18 : 16,
                    color: achievement.isUnlocked ? null : Colors.white24,
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
                          : Colors.white38,
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
                          ? SystemColors.textSecondary
                          : SystemColors.textMuted,
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
                        backgroundColor: Colors.black45,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            tierColor.withValues(alpha: 0.6)),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${achievement.currentProgress} / ${achievement.maxProgress}',
                      style: GoogleFonts.orbitron(
                        color: SystemColors.textMuted,
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
              color: achievement.isUnlocked ? tierColor : Colors.white24,
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
  Widget _buildWeeklyPerformance() {
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
          color: SystemColors.textSecondary,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
      child: Column(
        children: days.map((d) => _buildDayRow(d)).toList(),
      ),
    );
  }

  Widget _buildDayRow(_DayPerf day) {
    final pctText = '${(day.ratio * 100).toInt()}%';
    final barColor = day.ratio >= 1.0
        ? SystemColors.cyanGlow
        : day.ratio >= 0.5
            ? SystemColors.blueGlow
            : day.ratio > 0
                ? SystemColors.goldAccent
                : Colors.white.withValues(alpha: 0.1);

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
                    ? SystemColors.cyanGlow
                    : SystemColors.textSecondary,
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
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08)),
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
                                color:
                                    barColor.withValues(alpha: 0.3),
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
                    ? SystemColors.cyanGlow
                    : SystemColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (day.ratio >= 1.0) ...[
            const SizedBox(width: 4),
            const Icon(Icons.check_circle,
                color: SystemColors.cyanGlow, size: 14),
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
