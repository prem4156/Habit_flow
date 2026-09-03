import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quest_model.dart';
import '../services/system_state.dart';
import '../theme/system_theme.dart';
import '../widgets/system_window.dart';

class QuestScreen extends StatelessWidget {
  final SystemState state;

  const QuestScreen({super.key, required this.state});

  void _showAddQuestDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final targetCtrl = TextEditingController(text: '10');
    final unitCtrl = TextEditingController(text: 'mins');
    StatType selectedStat = StatType.str;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: SystemColors.panelBg,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: SystemColors.cyanGlow, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          title: Text(
            'REGISTER HUNTER QUEST',
            style: GoogleFonts.orbitron(
              color: SystemColors.cyanGlow,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: 'Quest / Habit Title',
                    hintText: 'e.g. Read Philosophy, Deep Work',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: 'System Description',
                    hintText: 'e.g. Elevate focus and mastery',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: targetCtrl,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(labelText: 'Target'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: unitCtrl,
                        style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(labelText: 'Unit (mins, reps)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      'Stat Boost: ',
                      style: GoogleFonts.rajdhani(
                        color: SystemColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<StatType>(
                      value: selectedStat,
                      dropdownColor: SystemColors.panelBg,
                      items: StatType.values.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(
                            '${s.code} (${s.label})',
                            style: GoogleFonts.rajdhani(color: SystemColors.cyanGlow),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedStat = val);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
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
                final target = int.tryParse(targetCtrl.text) ?? 10;
                if (titleCtrl.text.trim().isNotEmpty) {
                  state.addCustomQuest(
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim().isEmpty
                        ? 'Hunter daily training regimen.'
                        : descCtrl.text.trim(),
                    target: target,
                    unit: unitCtrl.text.trim().isEmpty ? 'reps' : unitCtrl.text.trim(),
                    statReward: selectedStat,
                    expReward: 50 + (target * 2).clamp(10, 100),
                    goldReward: 40 + (target * 2).clamp(10, 100),
                  );
                  Navigator.pop(ctx);
                }
              },
              child: Text(
                'REGISTER',
                style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dailyQuests = state.quests.where((q) => q.isDaily).toList();
    final customQuests = state.quests.where((q) => !q.isDaily).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Daily Quest Banner with Solo Leveling aesthetic
          SystemWindow(
            title: 'DAILY QUEST: PREPARING TO BECOME STRONG',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: SystemColors.cyanGlow.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: SystemColors.cyanGlow, width: 0.8),
              ),
              child: Text(
                '${state.completedDailyCount}/${state.totalDailyCount} CLEARED',
                style: GoogleFonts.orbitron(
                  color: SystemColors.cyanGlow,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GOAL: Complete all physical training and daily rituals before midnight to avert the Penalty Zone.',
                  style: GoogleFonts.rajdhani(
                    color: SystemColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: state.dailyCompletionRatio,
                    minHeight: 8,
                    backgroundColor: Colors.black45,
                    valueColor: const AlwaysStoppedAnimation<Color>(SystemColors.cyanGlow),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => state.resetDailyQuests(),
                      icon: const Icon(Icons.refresh, size: 14, color: SystemColors.textSecondary),
                      label: Text(
                        'RESET DAILIES',
                        style: GoogleFonts.orbitron(fontSize: 10, color: SystemColors.textSecondary),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: SystemColors.textSecondary.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => state.triggerPenaltyZone(),
                      icon: const Icon(Icons.warning, size: 14, color: Colors.white),
                      label: Text(
                        'PENALTY ZONE',
                        style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SystemColors.penaltyRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Daily Quest Items List
          ...dailyQuests.map((quest) => _buildQuestCard(context, quest)),

          const SizedBox(height: 16),

          // Custom Hunter Quests / Habits Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HUNTER HABIT CONTRACTS',
                style: GoogleFonts.orbitron(
                  color: SystemColors.cyanGlow,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAddQuestDialog(context),
                icon: const Icon(Icons.add_circle_outline, color: SystemColors.cyanGlow, size: 16),
                label: Text(
                  'NEW CONTRACT',
                  style: GoogleFonts.orbitron(
                    color: SystemColors.cyanGlow,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          if (customQuests.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                'No custom contracts registered. Tap "NEW CONTRACT" to add habits like reading, coding, or hydration.',
                style: GoogleFonts.rajdhani(
                  color: SystemColors.textMuted,
                  fontSize: 13,
                ),
              ),
            )
          else
            ...customQuests.map((quest) => _buildQuestCard(context, quest, isCustom: true)),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildQuestCard(BuildContext context, Quest quest, {bool isCustom = false}) {
    final isDone = quest.isCompleted;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDone ? SystemColors.panelBg.withValues(alpha: 0.4) : SystemColors.panelBg,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isDone
              ? SystemColors.hpGreen.withValues(alpha: 0.5)
              : SystemColors.cyanGlow.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: isDone
            ? []
            : [
                BoxShadow(
                  color: SystemColors.cyanGlow.withValues(alpha: 0.12),
                  blurRadius: 8,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quest Title & Reward Tag
          Row(
            children: [
              Icon(
                isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isDone ? SystemColors.hpGreen : SystemColors.cyanGlow,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  quest.title,
                  style: GoogleFonts.orbitron(
                    color: isDone ? SystemColors.textSecondary : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: SystemColors.cyanGlow.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '+1 ${quest.statReward.code}',
                      style: GoogleFonts.orbitron(
                        color: SystemColors.cyanGlow,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '• ${quest.expReward} EXP',
                      style: GoogleFonts.orbitron(
                        color: SystemColors.goldAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCustom)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.white38),
                  onPressed: () => state.deleteQuest(quest.id),
                  tooltip: 'Cancel Contract',
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            quest.description,
            style: GoogleFonts.rajdhani(
              color: SystemColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),

          // Progress Bar & Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '[ ${quest.current} / ${quest.target} ${quest.unit} ]',
                style: GoogleFonts.orbitron(
                  color: isDone ? SystemColors.hpGreen : SystemColors.cyanGlow,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (quest.streak > 0)
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.deepOrangeAccent, size: 14),
                    Text(
                      '${quest.streak} Day Streak',
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
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: quest.progress,
              minHeight: 6,
              backgroundColor: Colors.black45,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDone ? SystemColors.hpGreen : SystemColors.cyanGlow,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Increment Buttons or Cleared Banner
          if (isDone)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: SystemColors.hpGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  '[ CLEARED ]',
                  style: GoogleFonts.orbitron(
                    color: SystemColors.hpGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            )
          else
            _buildProgressButtons(quest),
        ],
      ),
    );
  }

  Widget _buildProgressButtons(Quest quest) {
    if (quest.target >= 100) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildQuickAddBtn(quest, 10, '+10'),
          const SizedBox(width: 8),
          _buildQuickAddBtn(quest, 25, '+25'),
          const SizedBox(width: 8),
          _buildQuickAddBtn(quest, quest.target - quest.current, 'DONE', isMax: true),
        ],
      );
    } else if (quest.target >= 10) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildQuickAddBtn(quest, 1, '+1'),
          const SizedBox(width: 8),
          _buildQuickAddBtn(quest, 5, '+5'),
          const SizedBox(width: 8),
          _buildQuickAddBtn(quest, quest.target - quest.current, 'DONE', isMax: true),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildQuickAddBtn(quest, 1, '+1'),
          const SizedBox(width: 8),
          _buildQuickAddBtn(quest, quest.target - quest.current, 'COMPLETE', isMax: true),
        ],
      );
    }
  }

  Widget _buildQuickAddBtn(Quest quest, int amount, String label, {bool isMax = false}) {
    return InkWell(
      onTap: () => state.incrementQuestProgress(quest.id, amount),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isMax ? SystemColors.cyanGlow : SystemColors.cyanGlow.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: SystemColors.cyanGlow, width: 0.8),
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
