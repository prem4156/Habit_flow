import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quest_model.dart';
import '../services/system_state.dart';
import '../theme/system_theme.dart';
import '../widgets/stat_row.dart';
import '../widgets/system_window.dart';

class StatusScreen extends StatelessWidget {
  final SystemState state;

  const StatusScreen({super.key, required this.state});

  void _showEditProfileDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: state.profile.name);
    final titleCtrl = TextEditingController(text: state.profile.title);
    final jobCtrl = TextEditingController(text: state.profile.job);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SystemColors.panelBg,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: SystemColors.cyanGlow, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(
          'UPDATE HUNTER DOSSIER',
          style: GoogleFonts.orbitron(
            color: SystemColors.cyanGlow,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(nameCtrl, 'Hunter Name'),
            const SizedBox(height: 12),
            _buildDialogField(titleCtrl, 'Hunter Title'),
            const SizedBox(height: 12),
            _buildDialogField(jobCtrl, 'Job / Class'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: GoogleFonts.orbitron(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SystemColors.cyanGlow,
              foregroundColor: Colors.black,
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

  Widget _buildDialogField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.rajdhani(color: SystemColors.cyanGlow),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: SystemColors.cyanGlow.withValues(alpha: 0.4)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: SystemColors.cyanGlow),
        ),
        filled: true,
        fillColor: Colors.black45,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = state.profile;
    final expRatio = profile.maxExp > 0 ? (profile.exp / profile.maxExp).clamp(0.0, 1.0) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Hunter Identity Card
          SystemWindow(
            title: 'Hunter Dossier',
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: SystemColors.cyanGlow, size: 18),
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
                    color: SystemColors.darkBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: SystemColors.cyanGlow, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: SystemColors.cyanGlow.withValues(alpha: 0.35),
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
                            color: SystemColors.cyanGlow,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'RANK',
                          style: GoogleFonts.orbitron(
                            color: SystemColors.textSecondary,
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
                          color: SystemColors.textPrimary,
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
                              color: SystemColors.cyanGlow.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: SystemColors.cyanGlow.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              profile.title,
                              style: GoogleFonts.rajdhani(
                                color: SystemColors.cyanGlow,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Job: ${profile.job}',
                            style: GoogleFonts.rajdhani(
                              color: SystemColors.textSecondary,
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
                          color: SystemColors.textMuted,
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
                        color: SystemColors.cyanGlow,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      '${profile.exp} / ${profile.maxExp} EXP',
                      style: GoogleFonts.orbitron(
                        color: SystemColors.textSecondary,
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
                    backgroundColor: Colors.black54,
                    valueColor: const AlwaysStoppedAnimation<Color>(SystemColors.cyanGlow),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daily Habits Cleared: ${state.completedDailyCount} / ${state.totalDailyCount}',
                      style: GoogleFonts.rajdhani(
                        color: SystemColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.monetization_on, color: SystemColors.goldAccent, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${profile.gold} Gold',
                          style: GoogleFonts.orbitron(
                            color: SystemColors.goldAccent,
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
                color: SystemColors.cyanGlow.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: SystemColors.cyanGlow, width: 0.8),
              ),
              child: Text(
                'TASK-FORGED',
                style: GoogleFonts.orbitron(
                  color: SystemColors.cyanGlow,
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
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: SystemColors.cyanGlow.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.fitness_center, color: SystemColors.cyanGlow, size: 14),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'SYSTEM LAW: Attributes elevate automatically upon clearing daily tasks.',
                          style: GoogleFonts.rajdhani(
                            color: SystemColors.textSecondary,
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
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
