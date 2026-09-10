import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/system_state.dart';
import '../theme/system_theme.dart';

/// A GitHub / HabitKit style day tracker heatmap grid for a single habit.
/// Displays daily completion history organized into 7 rows (days of the week)
/// across multiple weekly columns, ending at today on the right edge.
class HabitDayTrackerGrid extends StatelessWidget {
  final String questId;
  final SystemState state;
  final Color? activeColor;
  final int weeksCount;
  final bool isInteractive;

  const HabitDayTrackerGrid({
    super.key,
    required this.questId,
    required this.state,
    this.activeColor,
    this.weeksCount = 22,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final themeColor = activeColor ?? SystemColors.goldAccent;

    // Sunday = 0, Monday = 1, ..., Thursday = 4, Saturday = 6
    final int todayDayOfWeek = today.weekday % 7;
    final DateTime currentWeekSunday = today.subtract(Duration(days: todayDayOfWeek));

    return LayoutBuilder(
      builder: (context, constraints) {
        const double cellSize = 9.5;
        const double cellSpacing = 2.8;
        const double colWidth = cellSize + cellSpacing;

        // Auto-fit available width or use requested weeksCount
        int calculatedCols = weeksCount;
        if (constraints.maxWidth.isFinite && constraints.maxWidth > 0) {
          final int fitCols = (constraints.maxWidth / colWidth).floor();
          if (fitCols >= 10) {
            calculatedCols = fitCols;
          }
        }

        // Build columns from oldest (left) to newest / current week (right)
        final List<Widget> columns = [];

        for (int c = 0; c < calculatedCols; c++) {
          final int weekOffset = (calculatedCols - 1) - c;
          final DateTime weekSunday = currentWeekSunday.subtract(Duration(days: weekOffset * 7));

          final List<Widget> dayCells = [];
          for (int r = 0; r < 7; r++) {
            final DateTime cellDate = weekSunday.add(Duration(days: r));
            final bool isCellToday = cellDate.year == today.year &&
                cellDate.month == today.month &&
                cellDate.day == today.day;
            final bool isCellFuture = cellDate.isAfter(today);

            if (isCellFuture) {
              // Future days in current week are transparent placeholders
              dayCells.add(
                const SizedBox(
                  width: cellSize,
                  height: cellSize,
                ),
              );
            } else {
              final bool isCompleted = state.isQuestCompletedOnDate(questId, cellDate);
              dayCells.add(
                _buildCell(
                  context: context,
                  date: cellDate,
                  isToday: isCellToday,
                  isCompleted: isCompleted,
                  cellSize: cellSize,
                  activeColor: themeColor,
                ),
              );
            }

            if (r < 6) {
              dayCells.add(const SizedBox(height: cellSpacing));
            }
          }

          columns.add(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: dayCells,
            ),
          );

          if (c < calculatedCols - 1) {
            columns.add(const SizedBox(width: cellSpacing));
          }
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 2.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true, // Automatically scroll to the right (Today)
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: columns,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCell({
    required BuildContext context,
    required DateTime date,
    required bool isToday,
    required bool isCompleted,
    required double cellSize,
    required Color activeColor,
  }) {
    final String dateStr = _formatTooltipDate(date);
    final String statusStr = isCompleted ? 'Completed' : (isToday ? 'Due Today' : 'Missed');

    BoxDecoration decoration;
    if (isCompleted) {
      decoration = BoxDecoration(
        color: activeColor,
        borderRadius: BorderRadius.circular(2.2),
        boxShadow: [
          BoxShadow(
            color: activeColor.withValues(alpha: 0.5),
            blurRadius: 3.5,
            spreadRadius: 0.2,
          ),
        ],
      );
    } else if (isToday) {
      decoration = BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(2.2),
        border: Border.all(
          color: activeColor.withValues(alpha: 0.7),
          width: 0.9,
        ),
      );
    } else {
      decoration = BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(2.2),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 0.5,
        ),
      );
    }

    Widget cellWidget = Container(
      width: cellSize,
      height: cellSize,
      decoration: decoration,
    );

    if (isInteractive) {
      cellWidget = InkWell(
        onTap: () {
          try {
            HapticFeedback.selectionClick();
          } catch (_) {}
          state.toggleQuestComplete(questId, date: date);
        },
        borderRadius: BorderRadius.circular(2.2),
        child: cellWidget,
      );
    }

    return Tooltip(
      message: '$dateStr • $statusStr',
      waitDuration: const Duration(milliseconds: 250),
      child: cellWidget,
    );
  }

  String _formatTooltipDate(DateTime d) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dayName = days[d.weekday % 7];
    final monthName = months[d.month - 1];
    return '$dayName, ${d.day} $monthName';
  }
}
