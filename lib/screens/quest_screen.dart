import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quest_model.dart';
import '../services/system_state.dart';
import '../theme/system_theme.dart';
import '../widgets/calendar_hud_bar.dart';
import '../widgets/system_window.dart';

class QuestScreen extends StatefulWidget {
  final SystemState state;

  const QuestScreen({super.key, required this.state});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  bool _showCompletedQuests = false;

  void _showAddQuestDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final targetCtrl = TextEditingController(text: '10');
    final unitCtrl = TextEditingController(text: 'reps');
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
            'REGISTER REPEATING TASK',
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
                    labelText: 'Task / Habit Title',
                    hintText: 'e.g. Read Philosophy, Deep Work, Push-ups',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: 'System Description',
                    hintText: 'e.g. Elevate mental sharpness and endurance',
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
                        decoration: const InputDecoration(labelText: 'Target Goal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: unitCtrl,
                        style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(labelText: 'Unit (reps, mins, km)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'SELECT ATTRIBUTE (INCREASES AUTOMATICALLY):',
                    style: GoogleFonts.orbitron(
                      color: SystemColors.cyanGlow,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: StatType.values.map((s) {
                    final isSel = selectedStat == s;
                    return InkWell(
                      onTap: () => setDialogState(() => selectedStat = s),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? SystemColors.cyanGlow.withValues(alpha: 0.25) : Colors.black38,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSel ? SystemColors.cyanGlow : Colors.white24,
                            width: isSel ? 1.5 : 1.0,
                          ),
                        ),
                        child: Text(
                          '+1 ${s.code} (${s.label})',
                          style: GoogleFonts.rajdhani(
                            color: isSel ? SystemColors.cyanGlow : Colors.white70,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  'Clearing this task automatically increases Hunter ${selectedStat.label} (${selectedStat.code}) by +1.',
                  style: GoogleFonts.rajdhani(
                    color: SystemColors.hpGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
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
                  widget.state.addCustomQuest(
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

  void _showAttributeSelectionDialog(BuildContext context, Quest quest) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SystemColors.panelBg,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: SystemColors.cyanGlow, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(
          'SELECT ATTRIBUTE TARGET',
          style: GoogleFonts.orbitron(
            color: SystemColors.cyanGlow,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task: "${quest.title}"',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Select which attribute increases automatically when this task is completed:',
              style: GoogleFonts.rajdhani(
                color: SystemColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            ...StatType.values.map((stat) {
              final isSelected = quest.statReward == stat;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: InkWell(
                  onTap: () {
                    widget.state.updateQuestStatReward(quest.id, stat);
                    Navigator.pop(ctx);
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? SystemColors.cyanGlow.withValues(alpha: 0.22)
                          : Colors.black38,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected ? SystemColors.cyanGlow : Colors.white24,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          color: isSelected ? SystemColors.cyanGlow : Colors.white38,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          stat.code,
                          style: GoogleFonts.orbitron(
                            color: isSelected ? SystemColors.cyanGlow : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${stat.label})',
                          style: GoogleFonts.rajdhani(
                            color: SystemColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '+1 ${stat.code}',
                          style: GoogleFonts.orbitron(
                            color: isSelected ? SystemColors.cyanGlow : Colors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CLOSE',
              style: GoogleFonts.orbitron(color: Colors.white60),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final selectedDate = state.selectedDate;
    final isToday = state.isDateToday(selectedDate);
    final isPast = state.isDatePast(selectedDate);
    final isFuture = state.isDateFuture(selectedDate);

    final questsForDay = state.getQuestsForDate(selectedDate);
    final activeQuests = questsForDay.where((q) => !q.isCompleted).toList();
    final completedQuests = questsForDay.where((q) => q.isCompleted).toList();
    final totalCount = questsForDay.length;
    final completedCount = completedQuests.length;
    final ratio = totalCount > 0 ? (completedCount / totalCount).clamp(0.0, 1.0) : 0.0;

    String bannerTitle = 'DAILY QUEST: PREPARING TO BECOME STRONG';
    String bannerSubtitle =
        'GOAL: Complete all physical training and daily rituals before midnight to avert the Penalty Zone.';
    if (isPast) {
      bannerTitle = 'HISTORICAL LOG: ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
      bannerSubtitle = 'ARCHIVED PROTOCOL: Inspecting past daily task completions and performance.';
    } else if (isFuture) {
      bannerTitle = 'SCHEDULED PROTOCOL: ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
      bannerSubtitle = 'UPCOMING PROTOCOL: Daily recurring habits scheduled linearly for this date.';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Google Calendar-like Date Navigation HUD Strip
          CalendarHudBar(state: state),

          // Daily Quest Banner with Solo Leveling HUD aesthetic
          SystemWindow(
            title: bannerTitle,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: ratio == 1.0
                    ? SystemColors.hpGreen.withValues(alpha: 0.15)
                    : SystemColors.cyanGlow.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: ratio == 1.0 ? SystemColors.hpGreen : SystemColors.cyanGlow,
                  width: 0.8,
                ),
              ),
              child: Text(
                '$completedCount/$totalCount CLEARED',
                style: GoogleFonts.orbitron(
                  color: ratio == 1.0 ? SystemColors.hpGreen : SystemColors.cyanGlow,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bannerSubtitle,
                  style: GoogleFonts.rajdhani(
                    color: SystemColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 8,
                    backgroundColor: Colors.black45,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ratio == 1.0 ? SystemColors.hpGreen : SystemColors.cyanGlow,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isToday)
                      OutlinedButton.icon(
                        onPressed: () => state.resetDailyQuests(selectedDate),
                        icon: const Icon(Icons.refresh, size: 14, color: SystemColors.textSecondary),
                        label: Text(
                          'RESET DAILIES',
                          style: GoogleFonts.orbitron(fontSize: 10, color: SystemColors.textSecondary),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: SystemColors.textSecondary.withValues(alpha: 0.4)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: () => state.selectDate(DateTime.now()),
                        icon: const Icon(Icons.today, size: 14, color: SystemColors.cyanGlow),
                        label: Text(
                          'TODAY',
                          style: GoogleFonts.orbitron(fontSize: 10, color: SystemColors.cyanGlow),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: SystemColors.cyanGlow.withValues(alpha: 0.4)),
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

          const SizedBox(height: 10),

          // Emergency Quest Directive (if active)
          if (state.activeEmergencyQuest != null && !state.activeEmergencyQuest!.isCompleted)
            _buildEmergencyQuestCard(context, state),

          // Google Tasks Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.check_box_outlined, color: SystemColors.cyanGlow, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'TASKS • ${activeQuests.length} PENDING',
                    style: GoogleFonts.orbitron(
                      color: SystemColors.cyanGlow,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => _showAddQuestDialog(context),
                icon: const Icon(Icons.add_circle_outline, color: SystemColors.cyanGlow, size: 16),
                label: Text(
                  'NEW TASK',
                  style: GoogleFonts.orbitron(
                    color: SystemColors.cyanGlow,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Active Linear Tasks
          if (activeQuests.isEmpty && completedQuests.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  'No tasks registered. Tap "NEW TASK" to add daily repeating habits.',
                  style: GoogleFonts.rajdhani(color: SystemColors.textMuted, fontSize: 14),
                ),
              ),
            )
          else if (activeQuests.isEmpty && completedQuests.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: SystemColors.hpGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: SystemColors.hpGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: SystemColors.hpGreen, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ALL PROTOCOLS CLEARED!',
                          style: GoogleFonts.orbitron(
                            color: SystemColors.hpGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Hunter attributes successfully elevated for this date.',
                          style: GoogleFonts.rajdhani(
                            color: SystemColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            ...activeQuests.map((quest) => _buildActiveQuestCard(context, quest, selectedDate)),

          const SizedBox(height: 16),

          // Google Tasks Collapsible Completed Section
          if (completedQuests.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _showCompletedQuests = !_showCompletedQuests;
                    });
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          _showCompletedQuests
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_right,
                          color: SystemColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Completed (${completedQuests.length})',
                          style: GoogleFonts.orbitron(
                            color: SystemColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Divider(
                            color: Colors.white12,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showCompletedQuests)
                  ...completedQuests.map(
                    (quest) => _buildCompletedQuestCard(context, quest, selectedDate),
                  ),
              ],
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Active Quest Card (Google Tasks style with check-circle and quick progression)
  Widget _buildActiveQuestCard(BuildContext context, Quest quest, DateTime date) {
    final state = widget.state;
    final isCustom = quest.id.startsWith('custom_');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: SystemColors.panelBg,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: SystemColors.cyanGlow.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: SystemColors.cyanGlow.withValues(alpha: 0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Google Tasks Checkbox (One-tap complete)
              InkWell(
                onTap: () => state.toggleQuestComplete(quest.id, date: date),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: SystemColors.cyanGlow, width: 2),
                    color: Colors.black26,
                  ),
                  child: const Center(
                    child: Icon(Icons.circle, color: Colors.transparent, size: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
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
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      quest.description,
                      style: GoogleFonts.rajdhani(
                        color: SystemColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Attribute Badge with interactive attribute selector (+1 STR ▾)
              InkWell(
                onTap: () => _showAttributeSelectionDialog(context, quest),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SystemColors.cyanGlow.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: SystemColors.cyanGlow.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '+1 ${quest.statReward.code}',
                        style: GoogleFonts.orbitron(
                          color: SystemColors.cyanGlow,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_drop_down, color: SystemColors.cyanGlow, size: 14),
                    ],
                  ),
                ),
              ),
              if (isCustom)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.white38),
                  onPressed: () => state.deleteQuest(quest.id),
                  tooltip: 'Delete Habit',
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Linear Progress Bar & Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '[ ${quest.current} / ${quest.target} ${quest.unit} ]',
                style: GoogleFonts.orbitron(
                  color: SystemColors.cyanGlow,
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
              valueColor: const AlwaysStoppedAnimation<Color>(SystemColors.cyanGlow),
            ),
          ),
          const SizedBox(height: 10),

          // Stepper / Quick Add Buttons
          _buildProgressButtons(quest, date),
        ],
      ),
    );
  }

  // Completed Quest Card (Google Tasks style: strikethrough, dim, uncheck option)
  Widget _buildCompletedQuestCard(BuildContext context, Quest quest, DateTime date) {
    final state = widget.state;

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
      child: Row(
        children: [
          // Google Tasks Checked Box (Tap to uncheck/reopen)
          InkWell(
            onTap: () => state.toggleQuestComplete(quest.id, date: date),
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
                    decorationColor: Colors.white38,
                  ),
                ),
                Text(
                  'Completed • ${quest.target} ${quest.unit}',
                  style: GoogleFonts.rajdhani(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _showAttributeSelectionDialog(context, quest),
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
    );
  }

  Widget _buildProgressButtons(Quest quest, DateTime date) {
    if (quest.target >= 100) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildQuickAddBtn(quest, 10, '+10', date),
          const SizedBox(width: 8),
          _buildQuickAddBtn(quest, 25, '+25', date),
          const SizedBox(width: 8),
          _buildQuickAddBtn(quest, quest.target - quest.current, 'DONE', date, isMax: true),
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
          _buildQuickAddBtn(quest, quest.target - quest.current, 'DONE', date, isMax: true),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildQuickAddBtn(quest, 1, '+1', date),
          const SizedBox(width: 8),
          _buildQuickAddBtn(quest, quest.target - quest.current, 'COMPLETE', date, isMax: true),
        ],
      );
    }
  }

  Widget _buildQuickAddBtn(Quest quest, int amount, String label, DateTime date, {bool isMax = false}) {
    return InkWell(
      onTap: () => widget.state.incrementQuestProgress(quest.id, amount, date: date),
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

  Widget _buildEmergencyQuestCard(BuildContext context, SystemState state) {
    final quest = state.activeEmergencyQuest!;
    final progress = quest.progress;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: SystemColors.penaltyDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: SystemColors.penaltyRed, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: SystemColors.penaltyRed.withValues(alpha: 0.3),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: SystemColors.penaltyRed, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '⚠ EMERGENCY DIRECTIVE',
                    style: GoogleFonts.orbitron(
                      color: SystemColors.penaltyRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: SystemColors.penaltyRed.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: SystemColors.penaltyRed),
                  ),
                  child: Text(
                    'DEADLINE ${quest.deadline ?? "23:59"}',
                    style: GoogleFonts.orbitron(
                      color: SystemColors.penaltyRed,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              quest.title,
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              quest.description,
              style: GoogleFonts.rajdhani(
                color: SystemColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.black45,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    SystemColors.penaltyRed),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${quest.current} / ${quest.target} ${quest.unit}',
                  style: GoogleFonts.orbitron(
                    color: SystemColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '+${quest.expReward} EXP  +2 ${quest.statReward.code}',
                  style: GoogleFonts.orbitron(
                    color: SystemColors.penaltyRed,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Quick action buttons
            Row(
              children: [
                _buildEmergencyBtn(state, 1, '+1'),
                const SizedBox(width: 6),
                _buildEmergencyBtn(state, 5, '+5'),
                const SizedBox(width: 6),
                _buildEmergencyBtn(state, 10, '+10'),
                const Spacer(),
                InkWell(
                  onTap: () => state.incrementEmergencyQuestProgress(
                      quest.target - quest.current),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: SystemColors.penaltyRed,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'COMPLETE',
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => state.dismissEmergencyQuest(),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      'DISMISS',
                      style: GoogleFonts.orbitron(
                        color: Colors.white54,
                        fontSize: 10,
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
    );
  }

  Widget _buildEmergencyBtn(SystemState state, int amount, String label) {
    return InkWell(
      onTap: () => state.incrementEmergencyQuestProgress(amount),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: SystemColors.penaltyRed.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: SystemColors.penaltyRed, width: 0.8),
        ),
        child: Text(
          label,
          style: GoogleFonts.orbitron(
            color: SystemColors.penaltyRed,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
