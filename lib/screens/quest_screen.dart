import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quest_model.dart';
import '../services/system_state.dart';
import '../theme/system_theme.dart';
import '../widgets/calendar_hud_bar.dart';
import '../widgets/deadly_quest_card.dart';

class QuestScreen extends StatefulWidget {
  final SystemState state;

  const QuestScreen({super.key, required this.state});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  bool _showCompletedTasks = false;

  void _showPresetsLibraryModal(BuildContext context) {
    final isDark = SystemTheme.isDark(context);
    final accent = SystemTheme.getPrimaryAccent(context);
    final textPrimary = SystemTheme.getTextPrimary(context);
    final textSecondary = SystemTheme.getTextSecondary(context);
    final presets = Quest.presetTemplates();

    showModalBottomSheet(
      context: context,
      backgroundColor: SystemTheme.getPanelBg(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.library_add_check, color: accent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'PRESET PROTOCOL LIBRARY',
                        style: GoogleFonts.orbitron(
                          color: accent,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: textSecondary, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Text(
                'Select combat training, mental focus, and recovery habits to add to your daily regimen:',
                style: GoogleFonts.rajdhani(color: textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: presets.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final preset = presets[index];
                    final isAlreadyAdded = widget.state.allTemplateQuests
                        .any((q) => q.title.toLowerCase().trim() == preset.title.toLowerCase().trim());

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.7) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isAlreadyAdded
                              ? SystemTheme.getGreenAccent(context).withValues(alpha: 0.4)
                              : (isDark ? Colors.white12 : SystemColors.lightPanelBorder),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: accent.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              '+1 ${preset.statReward.code}',
                              style: GoogleFonts.orbitron(
                                color: accent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  preset.title,
                                  style: GoogleFonts.orbitron(
                                    color: textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${preset.description} • Target: ${preset.target} ${preset.unit}',
                                  style: GoogleFonts.rajdhani(
                                    color: textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isAlreadyAdded)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: SystemTheme.getGreenAccent(context).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'ACTIVE',
                                style: GoogleFonts.orbitron(
                                  color: SystemTheme.getGreenAccent(context),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                widget.state.addPresetQuest(preset);
                                Navigator.pop(ctx);
                              },
                              child: Text(
                                'ADD',
                                style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accent.withValues(alpha: 0.6)),
                        foregroundColor: accent,
                      ),
                      onPressed: () {
                        widget.state.restoreDefaultQuests();
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.restore, size: 16),
                      label: Text(
                        'RESTORE ALL DEFAULTS',
                        style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold),
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
  }

  void _showAddQuestDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final targetCtrl = TextEditingController(text: '10');
    final unitCtrl = TextEditingController(text: 'reps');
    StatType selectedStat = StatType.str;

    final isDark = SystemTheme.isDark(context);
    final accent = SystemTheme.getPrimaryAccent(context);
    final textPrimary = SystemTheme.getTextPrimary(context);
    final textSecondary = SystemTheme.getTextSecondary(context);
    final presets = Quest.presetTemplates();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: SystemTheme.getPanelBg(context),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: accent, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          title: Text(
            'REGISTER REPEATING TASK',
            style: GoogleFonts.orbitron(
              color: accent,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QUICK TEMPLATES (TAP TO AUTO-FILL):',
                  style: GoogleFonts.orbitron(
                    color: accent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: presets.map((p) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ActionChip(
                          backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          side: BorderSide(color: accent.withValues(alpha: 0.3)),
                          label: Text(
                            p.title,
                            style: GoogleFonts.rajdhani(
                              color: textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          onPressed: () {
                            setDialogState(() {
                              titleCtrl.text = p.title;
                              descCtrl.text = p.description;
                              targetCtrl.text = p.target.toString();
                              unitCtrl.text = p.unit;
                              selectedStat = p.statReward;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: 'Task / Habit Title',
                    hintText: 'e.g. Read Philosophy, Deep Work, Push-ups',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 16),
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
                        style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 16),
                        decoration: const InputDecoration(labelText: 'Target Goal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: unitCtrl,
                        style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 16),
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
                      color: accent,
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
                          color: isSel
                              ? accent.withValues(alpha: isDark ? 0.25 : 0.15)
                              : (isDark ? Colors.black38 : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSel ? accent : (isDark ? Colors.white24 : SystemColors.lightPanelBorder),
                            width: isSel ? 1.5 : 1.0,
                          ),
                        ),
                        child: Text(
                          '+1 ${s.code} (${s.label})',
                          style: GoogleFonts.rajdhani(
                            color: isSel ? accent : textSecondary,
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
                    color: SystemTheme.getGreenAccent(context),
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
                style: GoogleFonts.orbitron(color: textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
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
    final isDark = SystemTheme.isDark(context);
    final accent = SystemTheme.getPrimaryAccent(context);
    final textPrimary = SystemTheme.getTextPrimary(context);
    final textSecondary = SystemTheme.getTextSecondary(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SystemTheme.getPanelBg(context),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: accent, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(
          'SELECT ATTRIBUTE TARGET',
          style: GoogleFonts.orbitron(
            color: accent,
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
                color: textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Select which attribute increases automatically when this task is completed:',
              style: GoogleFonts.rajdhani(
                color: textSecondary,
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
                          ? accent.withValues(alpha: isDark ? 0.22 : 0.12)
                          : (isDark ? Colors.black38 : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected ? accent : (isDark ? Colors.white24 : SystemColors.lightPanelBorder),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          color: isSelected ? accent : (isDark ? Colors.white38 : SystemTheme.getTextMuted(context)),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          stat.code,
                          style: GoogleFonts.orbitron(
                            color: isSelected ? accent : textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${stat.label})',
                          style: GoogleFonts.rajdhani(
                            color: textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '+1 ${stat.code}',
                          style: GoogleFonts.orbitron(
                            color: isSelected ? accent : textSecondary,
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
              style: GoogleFonts.orbitron(color: textSecondary),
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
    final questsForDay = state.getQuestsForDate(selectedDate);
    final activeQuests = questsForDay.where((q) => !q.isCompleted).toList();
    final completedQuests = questsForDay.where((q) => q.isCompleted).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Google Calendar-like Date Navigation HUD Strip
          CalendarHudBar(state: state),

          const SizedBox(height: 4),

          // Emergency Quest Directive (if active)
          if (state.activeEmergencyQuest != null && !state.activeEmergencyQuest!.isCompleted)
            _buildEmergencyQuestCard(context, state),

          // Google Tasks Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.check_box_outlined, color: SystemTheme.getPrimaryAccent(context), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'TASKS • ${activeQuests.length} PENDING',
                    style: GoogleFonts.orbitron(
                      color: SystemTheme.getPrimaryAccent(context),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Preset Protocols',
                    icon: Icon(Icons.library_books_outlined, color: SystemTheme.getPrimaryAccent(context), size: 18),
                    onPressed: () => _showPresetsLibraryModal(context),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Default Protocols Menu',
                    icon: Icon(Icons.more_vert, color: SystemTheme.getTextSecondary(context), size: 18),
                    color: SystemTheme.getPanelBg(context),
                    onSelected: (val) {
                      if (val == 'restore') {
                        widget.state.restoreDefaultQuests();
                      } else if (val == 'reset_all') {
                        widget.state.resetToAllDefaults();
                      } else if (val == 'presets') {
                        _showPresetsLibraryModal(context);
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'restore',
                        child: Row(
                          children: [
                            Icon(Icons.restore, color: SystemTheme.getPrimaryAccent(context), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Restore Default Quests',
                              style: GoogleFonts.rajdhani(
                                color: SystemTheme.getTextPrimary(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'presets',
                        child: Row(
                          children: [
                            Icon(Icons.auto_awesome, color: SystemTheme.getPrimaryAccent(context), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Browse Preset Library',
                              style: GoogleFonts.rajdhani(
                                color: SystemTheme.getTextPrimary(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'reset_all',
                        child: Row(
                          children: [
                            const Icon(Icons.restart_alt, color: Colors.orangeAccent, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Reset All to Defaults',
                              style: GoogleFonts.rajdhani(
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddQuestDialog(context),
                    icon: Icon(Icons.add_circle_outline, color: SystemTheme.getPrimaryAccent(context), size: 16),
                    label: Text(
                      'NEW TASK',
                      style: GoogleFonts.orbitron(
                        color: SystemTheme.getPrimaryAccent(context),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Active Linear Tasks
          if (activeQuests.isEmpty && completedQuests.isEmpty)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: SystemTheme.isDark(context)
                    ? const Color(0xFF0F172A).withValues(alpha: 0.6)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: SystemTheme.isDark(context) ? Colors.white12 : SystemColors.lightPanelBorder,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 40,
                    color: SystemTheme.getTextSecondary(context).withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'NO PROTOCOLS REGISTERED',
                    style: GoogleFonts.orbitron(
                      color: SystemTheme.getTextPrimary(context),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Initialize your daily habit flow with default hunter protocols or register custom goals.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rajdhani(
                      color: SystemTheme.getTextSecondary(context),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SystemTheme.getPrimaryAccent(context),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => widget.state.restoreDefaultQuests(),
                        icon: const Icon(Icons.restore, size: 16),
                        label: Text(
                          'RESTORE DEFAULT TASKS',
                          style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: SystemTheme.getPrimaryAccent(context)),
                          foregroundColor: SystemTheme.getPrimaryAccent(context),
                        ),
                        onPressed: () => _showPresetsLibraryModal(context),
                        icon: const Icon(Icons.auto_awesome, size: 16),
                        label: Text(
                          'PRESET LIBRARY',
                          style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
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
            ...activeQuests.map((quest) => DeadlyQuestCard(
                  key: ValueKey('active_${quest.id}_${selectedDate.millisecondsSinceEpoch}'),
                  quest: quest,
                  date: selectedDate,
                  state: state,
                  onAttributeTap: () => _showAttributeSelectionDialog(context, quest),
                  isCompleted: false,
                )),

          const SizedBox(height: 16),

          // Google Tasks Collapsible Completed Section
          if (completedQuests.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _showCompletedTasks = !_showCompletedTasks;
                    });
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          _showCompletedTasks
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_right,
                          color: SystemTheme.getTextSecondary(context),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Completed (${completedQuests.length})',
                          style: GoogleFonts.orbitron(
                            color: SystemTheme.getTextSecondary(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Divider(
                            color: SystemTheme.getPanelBorder(context),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showCompletedTasks)
                  ...completedQuests.map(
                    (quest) => DeadlyQuestCard(
                      key: ValueKey('done_${quest.id}_${selectedDate.millisecondsSinceEpoch}'),
                      quest: quest,
                      date: selectedDate,
                      state: state,
                      onAttributeTap: () => _showAttributeSelectionDialog(context, quest),
                      isCompleted: true,
                    ),
                  ),
              ],
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildEmergencyQuestCard(BuildContext context, SystemState state) {
    final isDark = SystemTheme.isDark(context);
    final quest = state.activeEmergencyQuest!;
    final progress = quest.progress;
    final crimsonAccent = isDark ? SystemColors.crimsonGlow : const Color(0xFFE11D48);
    final cardBg = isDark ? SystemColors.crimsonDark : const Color(0xFFFFF1F2);
    final cardBorder = isDark ? SystemColors.crimsonGlow : const Color(0xFFFDA4AF);
    final titleColor = isDark ? Colors.white : const Color(0xFF881337);
    final descColor = isDark ? SystemColors.textSecondary : const Color(0xFF9F1239);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cardBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: crimsonAccent.withValues(alpha: isDark ? 0.3 : 0.12),
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
                Icon(Icons.warning_amber_rounded,
                    color: crimsonAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '⚠ EMERGENCY DIRECTIVE',
                    style: GoogleFonts.orbitron(
                      color: crimsonAccent,
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
                    color: crimsonAccent.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: crimsonAccent),
                  ),
                  child: Text(
                    'DEADLINE ${quest.deadline ?? "23:59"}',
                    style: GoogleFonts.orbitron(
                      color: crimsonAccent,
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
                color: titleColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              quest.description,
              style: GoogleFonts.rajdhani(
                color: descColor,
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
                backgroundColor: isDark ? Colors.black45 : const Color(0xFFFFE4E6),
                valueColor: AlwaysStoppedAnimation<Color>(crimsonAccent),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${quest.current} / ${quest.target} ${quest.unit}',
                  style: GoogleFonts.orbitron(
                    color: descColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '+${quest.expReward} EXP  +2 ${quest.statReward.code}',
                  style: GoogleFonts.orbitron(
                    color: crimsonAccent,
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
                _buildEmergencyBtn(context, state, 1, '+1'),
                const SizedBox(width: 6),
                _buildEmergencyBtn(context, state, 5, '+5'),
                const SizedBox(width: 6),
                _buildEmergencyBtn(context, state, 10, '+10'),
                const Spacer(),
                InkWell(
                  onTap: () => state.incrementEmergencyQuestProgress(
                      quest.target - quest.current),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: crimsonAccent,
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
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black12),
                    ),
                    child: Text(
                      'DISMISS',
                      style: GoogleFonts.orbitron(
                        color: isDark ? Colors.white54 : const Color(0xFF64748B),
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

  Widget _buildEmergencyBtn(BuildContext context, SystemState state, int amount, String label) {
    final isDark = SystemTheme.isDark(context);
    final crimsonAccent = isDark ? SystemColors.crimsonGlow : const Color(0xFFE11D48);

    return InkWell(
      onTap: () => state.incrementEmergencyQuestProgress(amount),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: crimsonAccent.withValues(alpha: isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: crimsonAccent, width: 0.8),
        ),
        child: Text(
          label,
          style: GoogleFonts.orbitron(
            color: crimsonAccent,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
