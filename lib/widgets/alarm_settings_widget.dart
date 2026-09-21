import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/system_state.dart';
import '../theme/system_theme.dart';

/// A themed "System Alarm" settings card for configuring daily reminders.
///
/// Displays a toggle switch and a time picker button, styled to match
/// the Solo Leveling dark/light UI of the app.
class AlarmSettingsWidget extends StatelessWidget {
  final SystemState state;
  const AlarmSettingsWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = SystemTheme.isDark(context);
    final accentColor = isDark ? SystemColors.cyanGlow : SystemColors.lightCyanGlow;
    final panelBg = isDark
        ? SystemColors.shadowBlack.withValues(alpha: 0.7)
        : Colors.white;
    final borderColor = isDark
        ? SystemColors.cyanGlow.withValues(alpha: 0.3)
        : SystemColors.lightPanelBorder;

    final timeStr = state.reminderTime != null
        ? '${state.reminderTime!.hour.toString().padLeft(2, '0')}:${state.reminderTime!.minute.toString().padLeft(2, '0')}'
        : '08:00';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isDark ? 1.2 : 1.4),
        boxShadow: [
          if (state.isReminderEnabled)
            BoxShadow(
              color: accentColor.withValues(alpha: isDark ? 0.15 : 0.12),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          if (!isDark)
            const BoxShadow(
              color: Color(0x0A0F172A),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: borderColor.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Alarm icon with glow effect
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withValues(alpha: state.isReminderEnabled ? 0.2 : 0.08),
                    boxShadow: state.isReminderEnabled
                        ? [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.4),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    state.isReminderEnabled ? Icons.alarm_on : Icons.alarm_off,
                    color: state.isReminderEnabled
                        ? accentColor
                        : SystemTheme.getTextMuted(context),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAILY QUEST ALARM',
                        style: GoogleFonts.orbitron(
                          color: SystemTheme.getTextPrimary(context),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.isReminderEnabled
                            ? 'System will remind you at $timeStr'
                            : 'No alarm scheduled',
                        style: GoogleFonts.rajdhani(
                          color: SystemTheme.getTextSecondary(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Toggle Switch
                Switch.adaptive(
                  value: state.isReminderEnabled,
                  onChanged: (enabled) => state.toggleReminder(enabled),
                  activeThumbColor: accentColor,
                  activeTrackColor: accentColor.withValues(alpha: 0.3),
                  inactiveThumbColor: SystemTheme.getTextMuted(context),
                  inactiveTrackColor: isDark
                      ? Colors.white10
                      : const Color(0xFFE2E8F0),
                ),
              ],
            ),
          ),

          // Time Picker Row
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: state.isReminderEnabled
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: SystemTheme.getTextSecondary(context),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'REMINDER TIME',
                          style: GoogleFonts.orbitron(
                            color: SystemTheme.getTextSecondary(context),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const Spacer(),
                        // Time button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _pickTime(context),
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.5),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withValues(alpha: 0.15),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    timeStr,
                                    style: GoogleFonts.orbitron(
                                      color: accentColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.edit,
                                    color: accentColor.withValues(alpha: 0.7),
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final isDark = SystemTheme.isDark(context);
    final accentColor = isDark ? SystemColors.cyanGlow : SystemColors.lightCyanGlow;

    final picked = await showTimePicker(
      context: context,
      initialTime: state.reminderTime ?? const TimeOfDay(hour: 8, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: accentColor,
                    onPrimary: Colors.black,
                    surface: const Color(0xFF1A1A2E),
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: accentColor,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: SystemColors.lightTextPrimary,
                  ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
              dialHandColor: accentColor,
              hourMinuteColor: accentColor.withValues(alpha: isDark ? 0.15 : 0.12),
              hourMinuteTextColor: isDark ? Colors.white : SystemColors.lightTextPrimary,
              dayPeriodColor: accentColor.withValues(alpha: isDark ? 0.15 : 0.12),
              dayPeriodTextColor: isDark ? Colors.white : SystemColors.lightTextPrimary,
              entryModeIconColor: accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: accentColor.withValues(alpha: isDark ? 0.3 : 0.5)),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      state.setReminderTime(picked);
    }
  }
}
