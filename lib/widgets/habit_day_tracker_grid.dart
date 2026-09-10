import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/system_state.dart';
import '../theme/system_theme.dart';

/// A GitHub / HabitKit style full-year 365/366 day completion heatmap grid.
/// Each dot corresponds to one specific calendar day of the current year (Jan 1 - Dec 31).
/// Automatically updates in real time when tasks are completed, persisted locally,
/// and highlights today's position with auto-scroll.
class HabitDayTrackerGrid extends StatefulWidget {
  final String questId;
  final SystemState state;
  final Color? activeColor;
  final bool isInteractive;
  final int? year;
  final bool showHeader;

  const HabitDayTrackerGrid({
    super.key,
    required this.questId,
    required this.state,
    this.activeColor,
    this.isInteractive = true,
    this.year,
    this.showHeader = true,
  });

  @override
  State<HabitDayTrackerGrid> createState() => _HabitDayTrackerGridState();
}

class _HabitDayTrackerGridState extends State<HabitDayTrackerGrid> {
  final ScrollController _scrollController = ScrollController();
  bool _hasAutoScrolled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
  }

  @override
  void didUpdateWidget(covariant HabitDayTrackerGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questId != widget.questId || oldWidget.year != widget.year) {
      _hasAutoScrolled = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToToday();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToToday() {
    if (!mounted || !_scrollController.hasClients || _hasAutoScrolled) return;

    final targetYear = widget.year ?? DateTime.now().year;
    final now = DateTime.now();

    if (now.year == targetYear) {
      final jan1 = DateTime(targetYear, 1, 1);
      final int startOffset = jan1.weekday % 7;
      final int todayDoy = SystemState.getDayOfYear(now);
      final int todayCol = (todayDoy - 1 + startOffset) ~/ 7;

      const double cellSize = 9.5;
      const double cellSpacing = 2.8;
      const double colWidth = cellSize + cellSpacing;

      final double targetOffset = max(0.0, (todayCol * colWidth) - 120.0);
      final double maxScroll = _scrollController.position.maxScrollExtent;
      final double scrollPos = min(targetOffset, maxScroll);

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          scrollPos,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
        _hasAutoScrolled = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        final targetYear = widget.year ?? DateTime.now().year;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final themeColor = widget.activeColor ?? SystemColors.hpGreen;

        final int totalDays = SystemState.getTotalDaysInYear(targetYear);
        final jan1 = DateTime(targetYear, 1, 1);

        // Day of week offset for Jan 1: Sunday = 0, Monday = 1, ..., Saturday = 6
        final int startDayOfWeek = jan1.weekday % 7;

        // Total columns needed for the year
        final int totalColumns = ((totalDays + startDayOfWeek) / 7).ceil();

        const double cellSize = 9.5;
        const double cellSpacing = 2.8;
        const double colWidth = cellSize + cellSpacing;

        // Month labels placement
        final List<Widget> monthHeaderLabels = [];
        int lastMonth = -1;

        // Build weekly columns from Week 1 (Jan 1) to Week 53 (Dec 31)
        final List<Widget> weekColumns = [];

        int dayOfYearCounter = 1;

        for (int col = 0; col < totalColumns; col++) {
          final List<Widget> dayCells = [];
          String? colMonthLabel;

          for (int row = 0; row < 7; row++) {
            // Slots before Jan 1 in the first week
            if (col == 0 && row < startDayOfWeek) {
              dayCells.add(
                const SizedBox(
                  width: cellSize,
                  height: cellSize,
                ),
              );
            } else if (dayOfYearCounter <= totalDays) {
              final int currentDoy = dayOfYearCounter;
              final DateTime cellDate = jan1.add(Duration(days: currentDoy - 1));

              // Record month label for the first time a month appears
              if (cellDate.month != lastMonth && row == 0) {
                lastMonth = cellDate.month;
                colMonthLabel = _monthAbbr(cellDate.month);
              }

              final bool isCellToday = targetYear == now.year &&
                  cellDate.month == now.month &&
                  cellDate.day == now.day;
              final bool isCellFuture = cellDate.isAfter(today);
              final bool isCompleted = widget.state.isTaskCompletedOnDayOfYear(
                widget.questId,
                currentDoy,
                year: targetYear,
              );

              dayCells.add(
                _buildDotCell(
                  context: context,
                  date: cellDate,
                  dayOfYear: currentDoy,
                  isToday: isCellToday,
                  isFuture: isCellFuture,
                  isCompleted: isCompleted,
                  cellSize: cellSize,
                  activeColor: themeColor,
                ),
              );

              dayOfYearCounter++;
            } else {
              // Slots after Dec 31 in the last week
              dayCells.add(
                const SizedBox(
                  width: cellSize,
                  height: cellSize,
                ),
              );
            }

            if (row < 6) {
              dayCells.add(const SizedBox(height: cellSpacing));
            }
          }

          weekColumns.add(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: dayCells,
            ),
          );

          if (col < totalColumns - 1) {
            weekColumns.add(const SizedBox(width: cellSpacing));
          }

          // Header month label tracker
          monthHeaderLabels.add(
            SizedBox(
              width: colWidth,
              child: Text(
                colMonthLabel ?? '',
                style: GoogleFonts.orbitron(
                  color: Colors.white38,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.visible,
              ),
            ),
          );
        }

        final completedDays = widget.state.getCompletedDaysForTask(widget.questId, year: targetYear);
        final completedCount = completedDays.length;
        final double percent = totalDays > 0 ? (completedCount / totalDays) * 100 : 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showHeader) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, size: 11, color: themeColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '$targetYear ($totalDays DAYS)',
                        style: GoogleFonts.orbitron(
                          color: SystemColors.textSecondary,
                          fontSize: 9,
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: completedCount > 0
                            ? themeColor.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: completedCount > 0
                              ? themeColor.withValues(alpha: 0.5)
                              : Colors.white12,
                          width: 0.6,
                        ),
                      ),
                      child: Text(
                        '$completedCount/$totalDays (${percent.toStringAsFixed(0)}%)',
                        style: GoogleFonts.orbitron(
                          color: completedCount > 0 ? themeColor : Colors.white60,
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Horizontal Scrollable Grid of 365/366 Dots
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white.withValues(alpha: 0.04), width: 0.8),
              ),
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Month labels bar
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: monthHeaderLabels,
                      ),
                    ),
                    // 7-row dots matrix
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: weekColumns,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDotCell({
    required BuildContext context,
    required DateTime date,
    required int dayOfYear,
    required bool isToday,
    required bool isFuture,
    required bool isCompleted,
    required double cellSize,
    required Color activeColor,
  }) {
    final String dateStr = _formatTooltipDate(date);
    final String statusStr = isCompleted
        ? 'CLEARED'
        : (isToday ? 'DUE TODAY' : (isFuture ? 'UPCOMING' : 'MISSED'));

    BoxDecoration decoration;
    if (isCompleted) {
      decoration = BoxDecoration(
        color: activeColor,
        borderRadius: BorderRadius.circular(2.2),
        boxShadow: [
          BoxShadow(
            color: activeColor.withValues(alpha: 0.65),
            blurRadius: 4.0,
            spreadRadius: 0.4,
          ),
        ],
      );
    } else if (isToday) {
      decoration = BoxDecoration(
        color: const Color(0xFF1E2337),
        borderRadius: BorderRadius.circular(2.2),
        border: Border.all(
          color: SystemColors.cyanGlow,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: SystemColors.cyanGlow.withValues(alpha: 0.4),
            blurRadius: 3.0,
          ),
        ],
      );
    } else if (isFuture) {
      decoration = BoxDecoration(
        color: const Color(0xFF10121A),
        borderRadius: BorderRadius.circular(2.2),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.04),
          width: 0.5,
        ),
      );
    } else {
      // Past missed day
      decoration = BoxDecoration(
        color: const Color(0xFF161924),
        borderRadius: BorderRadius.circular(2.2),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 0.6,
        ),
      );
    }

    Widget cellWidget = Container(
      width: cellSize,
      height: cellSize,
      decoration: decoration,
    );

    if (widget.isInteractive) {
      cellWidget = InkWell(
        onTap: () {
          try {
            HapticFeedback.selectionClick();
          } catch (_) {}
          widget.state.toggleQuestComplete(widget.questId, date: date);
        },
        borderRadius: BorderRadius.circular(2.2),
        child: cellWidget,
      );
    }

    return Tooltip(
      message: 'Day $dayOfYear • $dateStr\nStatus: $statusStr',
      waitDuration: const Duration(milliseconds: 200),
      textStyle: GoogleFonts.rajdhani(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: const Color(0xFF0F121C),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isCompleted ? activeColor : (isToday ? SystemColors.cyanGlow : Colors.white24), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 8,
          ),
        ],
      ),
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
    return '$dayName, ${d.day} $monthName ${d.year}';
  }

  String _monthAbbr(int m) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    if (m >= 1 && m <= 12) return months[m - 1];
    return '';
  }
}
