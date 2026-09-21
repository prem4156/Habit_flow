import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quest_model.dart';
import '../models/achievement_model.dart';
import '../services/system_state.dart';
import '../theme/system_theme.dart';
import '../widgets/stat_row.dart';
import '../widgets/system_window.dart';
import '../widgets/alarm_settings_widget.dart';

class StatusScreen extends StatelessWidget {
  final SystemState state;

  const StatusScreen({super.key, required this.state});

  void _showEditProfileDialog(BuildContext context) {
    final isDark = SystemTheme.isDark(context);
    final accent = SystemTheme.getPrimaryAccent(context);
    final textPrimary = SystemTheme.getTextPrimary(context);
    final textSecondary = SystemTheme.getTextSecondary(context);

    final nameCtrl = TextEditingController(text: state.profile.name);
    final titleCtrl = TextEditingController(text: state.profile.title);
    final jobCtrl = TextEditingController(text: state.profile.job);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SystemTheme.getPanelBg(context),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: accent, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(
          'UPDATE HUNTER DOSSIER',
          style: GoogleFonts.orbitron(
            color: accent,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(nameCtrl, 'Hunter Name', textPrimary, accent, isDark),
            const SizedBox(height: 12),
            _buildDialogField(titleCtrl, 'Hunter Title', textPrimary, accent, isDark),
            const SizedBox(height: 12),
            _buildDialogField(jobCtrl, 'Job / Class', textPrimary, accent, isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: GoogleFonts.orbitron(color: textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              state.updateHunterDetails(
                name: nameCtrl.text,
                title: titleCtrl.text,
                job: jobCtrl.text,
              );
              Navigator.pop(ctx);
            },
            child: Text(
              'SAVE',
              style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(
    TextEditingController ctrl,
    String label,
    Color textPrimary,
    Color accent,
    bool isDark,
  ) {
    return TextField(
      controller: ctrl,
      style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.rajdhani(color: accent),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? accent.withValues(alpha: 0.4) : SystemColors.lightPanelBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        filled: true,
        fillColor: isDark ? Colors.black45 : const Color(0xFFF1F5F9),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = state.profile;
    final expRatio = profile.maxExp > 0 ? (profile.exp / profile.maxExp).clamp(0.0, 1.0) : 0.0;
    final isDark = SystemTheme.isDark(context);
    final accent = SystemTheme.getPrimaryAccent(context);
    final textPrimary = SystemTheme.getTextPrimary(context);
    final textSecondary = SystemTheme.getTextSecondary(context);
    final textMuted = SystemTheme.getTextMuted(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Hunter Identity Card
          SystemWindow(
            title: 'Hunter Dossier',
            trailing: IconButton(
              icon: Icon(Icons.edit, color: accent, size: 18),
              onPressed: () => _showEditProfileDialog(context),
              tooltip: 'Edit Hunter Details',
            ),
            child: Row(
              children: [
                // Hunter Rank Crest
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isDark ? SystemColors.darkBlue : const Color(0xFFE0F2FE),
                    shape: BoxShape.circle,
                    border: Border.all(color: accent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: isDark ? 0.35 : 0.2),
                        blurRadius: 14,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          profile.rank.label.split('-')[0],
                          style: GoogleFonts.orbitron(
                            color: accent,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'RANK',
                          style: GoogleFonts.orbitron(
                            color: textSecondary,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Hunter Name and Meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name.toUpperCase(),
                        style: GoogleFonts.orbitron(
                          color: textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: isDark ? 0.15 : 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: accent.withValues(alpha: isDark ? 0.4 : 0.5)),
                            ),
                            child: Text(
                              profile.title,
                              style: GoogleFonts.rajdhani(
                                color: accent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Job: ${profile.job}',
                            style: GoogleFonts.rajdhani(
                              color: textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        profile.rank.description,
                        style: GoogleFonts.rajdhani(
                          color: textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Level & EXP Progress
          SystemWindow(
            title: 'Progression Level',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LEVEL ${profile.level}',
                      style: GoogleFonts.orbitron(
                        color: accent,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      '${profile.exp} / ${profile.maxExp} EXP',
                      style: GoogleFonts.orbitron(
                        color: textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: expRatio,
                    minHeight: 10,
                    backgroundColor: SystemTheme.getProgressTrack(context),
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daily Habits Cleared: ${state.completedDailyCount} / ${state.totalDailyCount}',
                      style: GoogleFonts.rajdhani(
                        color: textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: accent, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${state.totalQuestClears} Tasks Cleared',
                          style: GoogleFonts.orbitron(
                            color: accent,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Attributes & Task-Driven Growth
          SystemWindow(
            title: 'Hunter Attributes',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: accent.withValues(alpha: isDark ? 0.8 : 0.5), width: 0.8),
              ),
              child: Text(
                'TASK-FORGED',
                style: GoogleFonts.orbitron(
                  color: accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 10.0),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black45 : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isDark ? accent.withValues(alpha: 0.3) : SystemColors.lightPanelBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.fitness_center, color: accent, size: 14),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'SYSTEM LAW: Attributes elevate automatically upon clearing daily tasks.',
                          style: GoogleFonts.rajdhani(
                            color: textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                StatRow(
                  statType: StatType.str,
                  value: profile.stats.strength,
                  gainsFromTasks: state.statGainsFromQuests['STR'] ?? 0,
                ),
                StatRow(
                  statType: StatType.agi,
                  value: profile.stats.agility,
                  gainsFromTasks: state.statGainsFromQuests['AGI'] ?? 0,
                ),
                StatRow(
                  statType: StatType.vit,
                  value: profile.stats.vitality,
                  gainsFromTasks: state.statGainsFromQuests['VIT'] ?? 0,
                ),
                StatRow(
                  statType: StatType.intl,
                  value: profile.stats.intelligence,
                  gainsFromTasks: state.statGainsFromQuests['INT'] ?? 0,
                ),
                StatRow(
                  statType: StatType.per,
                  value: profile.stats.perception,
                  gainsFromTasks: state.statGainsFromQuests['PER'] ?? 0,
                ),
              ],
            ),
          ),

          // System Achievements & Feats
          SystemWindow(
            title: 'System Achievements & Feats',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: SystemTheme.getPurpleAccent(context).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: SystemTheme.getPurpleAccent(context), width: 0.8),
              ),
              child: Text(
                '${state.achievements.where((a) => a.isUnlocked).length}/${state.achievements.length}',
                style: GoogleFonts.orbitron(
                  color: SystemTheme.getPurpleAccent(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            child: Column(
              children: [
                ...state.achievements.map((achievement) => _buildAchievementRow(context, achievement)),
              ],
            ),
          ),

          // System Intervention / Diagnostic
          SystemWindow(
            title: 'System Autonomous Engine',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 10.0),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black45 : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: SystemTheme.getPrimaryAccent(context).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: SystemTheme.getPrimaryAccent(context), size: 14),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'The System monitors your discipline autonomously. Emergency Quests and Achievements may trigger at any time.',
                          style: GoogleFonts.rajdhani(
                            color: SystemTheme.getTextSecondary(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consecutive Perfect Days: ${state.consecutivePerfectDays}',
                          style: GoogleFonts.rajdhani(
                            color: SystemTheme.getTextSecondary(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Total Tasks Cleared: ${state.totalQuestClears}',
                          style: GoogleFonts.rajdhani(
                            color: SystemTheme.getTextSecondary(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => state.simulateAutonomousIntervention(),
                      icon: const Icon(Icons.bolt, size: 16),
                      label: Text(
                        'TRIGGER SYSTEM',
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SystemTheme.getCrimsonAccent(context),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Daily Quest Alarm Settings
          AlarmSettingsWidget(state: state),

          // System Theme Calibration (Dark / Light / Adaptive)
          SystemWindow(
            title: 'System Interface Calibration',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 1. Shadow Monarch Dark Card
                    Expanded(
                      child: InkWell(
                        onTap: () => state.setThemeMode(ThemeMode.dark),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                          decoration: BoxDecoration(
                            color: (!state.isAdaptiveThemeEnabled && state.themeMode == ThemeMode.dark)
                                ? SystemColors.monarchDark.withValues(alpha: 0.8)
                                : (isDark ? Colors.black26 : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: (!state.isAdaptiveThemeEnabled && state.themeMode == ThemeMode.dark)
                                  ? SystemColors.cyanGlow
                                  : (isDark ? Colors.transparent : const Color(0xFFE2E8F0)),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.dark_mode,
                                color: (!state.isAdaptiveThemeEnabled && state.themeMode == ThemeMode.dark)
                                    ? SystemColors.cyanGlow
                                    : SystemTheme.getTextMuted(context),
                                size: 22,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'SHADOW',
                                style: GoogleFonts.orbitron(
                                  color: (!state.isAdaptiveThemeEnabled && state.themeMode == ThemeMode.dark)
                                      ? SystemColors.cyanGlow
                                      : SystemTheme.getTextPrimary(context),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Dark HUD',
                                style: GoogleFonts.rajdhani(
                                  color: SystemTheme.getTextSecondary(context),
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 2. Radiant System Light Card
                    Expanded(
                      child: InkWell(
                        onTap: () => state.setThemeMode(ThemeMode.light),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                          decoration: BoxDecoration(
                            color: (!state.isAdaptiveThemeEnabled && state.themeMode == ThemeMode.light)
                                ? SystemColors.lightCyanGlow.withValues(alpha: 0.15)
                                : (isDark ? Colors.black26 : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: (!state.isAdaptiveThemeEnabled && state.themeMode == ThemeMode.light)
                                  ? (isDark ? SystemColors.lightCyanGlow : const Color(0xFF0284C7))
                                  : (isDark ? Colors.transparent : const Color(0xFFE2E8F0)),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.light_mode,
                                color: (!state.isAdaptiveThemeEnabled && state.themeMode == ThemeMode.light)
                                    ? SystemTheme.getGoldAccent(context)
                                    : SystemTheme.getTextMuted(context),
                                size: 22,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'RADIANT',
                                style: GoogleFonts.orbitron(
                                  color: (!state.isAdaptiveThemeEnabled && state.themeMode == ThemeMode.light)
                                      ? (isDark ? SystemColors.lightCyanGlow : const Color(0xFF0284C7))
                                      : SystemTheme.getTextPrimary(context),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Light HUD',
                                style: GoogleFonts.rajdhani(
                                  color: SystemTheme.getTextSecondary(context),
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 3. Solar Adaptive Card
                    Expanded(
                      child: InkWell(
                        onTap: () => state.setAdaptiveTheme(true),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                          decoration: BoxDecoration(
                            color: state.isAdaptiveThemeEnabled
                                ? (state.isDaytimeNow
                                    ? SystemTheme.getGoldAccent(context).withValues(alpha: 0.15)
                                    : SystemTheme.getPurpleAccent(context).withValues(alpha: 0.15))
                                : (isDark ? Colors.black26 : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: state.isAdaptiveThemeEnabled
                                  ? (state.isDaytimeNow ? SystemTheme.getGoldAccent(context) : SystemTheme.getPurpleAccent(context))
                                  : (isDark ? Colors.transparent : const Color(0xFFE2E8F0)),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.brightness_auto,
                                color: state.isAdaptiveThemeEnabled
                                    ? (state.isDaytimeNow ? SystemTheme.getGoldAccent(context) : SystemTheme.getPurpleAccent(context))
                                    : SystemTheme.getTextMuted(context),
                                size: 22,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'ADAPTIVE',
                                style: GoogleFonts.orbitron(
                                  color: state.isAdaptiveThemeEnabled
                                      ? (state.isDaytimeNow ? SystemTheme.getGoldAccent(context) : SystemTheme.getPurpleAccent(context))
                                      : SystemTheme.getTextPrimary(context),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Auto Time',
                                style: GoogleFonts.rajdhani(
                                  color: SystemTheme.getTextSecondary(context),
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Adaptive Time Sync Protocol details tile
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black38 : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: state.isAdaptiveThemeEnabled
                          ? (state.isDaytimeNow ? SystemTheme.getGoldAccent(context).withValues(alpha: 0.5) : SystemTheme.getPurpleAccent(context).withValues(alpha: 0.5))
                          : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            state.isAdaptiveThemeEnabled
                                ? (state.isDaytimeNow ? Icons.wb_sunny : Icons.nightlight_round)
                                : Icons.schedule,
                            color: state.isAdaptiveThemeEnabled
                                ? (state.isDaytimeNow ? SystemTheme.getGoldAccent(context) : SystemTheme.getPurpleAccent(context))
                                : SystemTheme.getTextSecondary(context),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SOLAR TIME SYNC PROTOCOL',
                                  style: GoogleFonts.orbitron(
                                    color: SystemTheme.getTextPrimary(context),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '06:00 - 18:00 (Radiant Light) • 18:00 - 06:00 (Shadow Dark)',
                                  style: GoogleFonts.rajdhani(
                                    color: SystemTheme.getTextSecondary(context),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: state.isAdaptiveThemeEnabled,
                            activeThumbColor: state.isDaytimeNow ? SystemTheme.getGoldAccent(context) : SystemTheme.getPurpleAccent(context),
                            onChanged: (val) => state.setAdaptiveTheme(val),
                          ),
                        ],
                      ),
                      if (state.isAdaptiveThemeEnabled) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (state.isDaytimeNow ? SystemTheme.getGoldAccent(context) : SystemTheme.getPurpleAccent(context)).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                state.isDaytimeNow ? Icons.wb_sunny_outlined : Icons.bedtime_outlined,
                                size: 14,
                                color: state.isDaytimeNow ? SystemTheme.getGoldAccent(context) : SystemTheme.getPurpleAccent(context),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                state.isDaytimeNow
                                    ? 'CURRENT PHASE: ☀️ DAYTIME DETECTED → RADIANT LIGHT HUD'
                                    : 'CURRENT PHASE: 🌙 NIGHTTIME DETECTED → SHADOW MONARCH HUD',
                                style: GoogleFonts.orbitron(
                                  color: state.isDaytimeNow ? SystemTheme.getGoldAccent(context) : SystemTheme.getPurpleAccent(context),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
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
              : (isDark ? Colors.black38 : Colors.white),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: achievement.isUnlocked
                ? tierColor.withValues(alpha: isDark ? 0.5 : 0.65)
                : (isDark ? Colors.white.withValues(alpha: 0.1) : SystemColors.lightPanelBorder),
            width: achievement.isUnlocked ? 1.2 : 1.0,
          ),
          boxShadow: [
            if (!isDark)
              const BoxShadow(
                color: Color(0x060F172A),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            // Badge
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
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: GoogleFonts.orbitron(
                      color: achievement.isUnlocked ? tierColor : SystemTheme.getTextMuted(context),
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
                  if (!achievement.isUnlocked && achievement.maxProgress > 1) ...[
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
            // Status icon
            Icon(
              achievement.isUnlocked ? Icons.check_circle : Icons.lock_outline,
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
}
