import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/system_state.dart';
import '../theme/system_theme.dart';

class CalendarHudBar extends StatefulWidget {
  final SystemState state;

  const CalendarHudBar({super.key, required this.state});

  @override
  State<CalendarHudBar> createState() => _CalendarHudBarState();
}

class _CalendarHudBarState extends State<CalendarHudBar> {
  final ScrollController _scrollController = ScrollController();
  static const int _daysBefore = 14;
  static const int _daysAfter = 14;
  static const double _itemWidth = 58.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected(animate: false);
    });
  }

  void _scrollToSelected({bool animate = true}) {
    if (!_scrollController.hasClients) return;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      widget.state.selectedDate.year,
      widget.state.selectedDate.month,
      widget.state.selectedDate.day,
    );
    final diffDays = selected.difference(today).inDays;
    final targetIndex = _daysBefore + diffDays;

    if (targetIndex >= 0 && targetIndex < (_daysBefore + _daysAfter + 1)) {
      final screenWidth = MediaQuery.of(context).size.width;
      final targetOffset = (targetIndex * (_itemWidth + 8.0)) - (screenWidth / 2) + (_itemWidth / 2) + 16.0;
      final safeOffset = targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent);

      if (animate) {
        _scrollController.animateTo(
          safeOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      } else {
        _scrollController.jumpTo(safeOffset);
      }
    }
  }

  String _getMonthName(int month) {
    const months = [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
    ];
    return months[month - 1];
  }

  String _getWeekdayName(int weekday) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[weekday - 1];
  }

  Future<void> _pickCustomDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.state.selectedDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: SystemColors.cyanGlow,
              onPrimary: Colors.black,
              surface: SystemColors.panelBg,
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: SystemColors.panelBg,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      widget.state.selectDate(picked);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = widget.state.selectedDate;
    final isSelectedToday = widget.state.isDateToday(selectedDate);

    // List of dates from past 14 days to next 14 days
    final dates = List.generate(_daysBefore + _daysAfter + 1, (i) {
      return today.add(Duration(days: i - _daysBefore));
    });

    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        color: SystemColors.panelBg.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: SystemColors.cyanGlow.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: SystemColors.cyanGlow.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Month Header & Navigation Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
            child: Row(
              children: [
                Icon(Icons.calendar_month, color: SystemColors.cyanGlow, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${_getMonthName(selectedDate.month)} ${selectedDate.year}',
                  style: GoogleFonts.orbitron(
                    color: SystemColors.cyanGlow,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                // Fast Jump to Today
                if (!isSelectedToday)
                  GestureDetector(
                    onTap: () {
                      widget.state.selectDate(DateTime.now());
                      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: SystemColors.cyanGlow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: SystemColors.cyanGlow, width: 1),
                      ),
                      child: Text(
                        'TODAY',
                        style: GoogleFonts.orbitron(
                          color: SystemColors.cyanGlow,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Date picker modal button
                IconButton(
                  icon: const Icon(Icons.date_range, color: Colors.white70, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Pick Date',
                  onPressed: () => _pickCustomDate(context),
                ),
                const SizedBox(width: 8),
                // Previous Day Button
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: SystemColors.cyanGlow, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Previous Day',
                  onPressed: () {
                    widget.state.selectDate(selectedDate.subtract(const Duration(days: 1)));
                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
                  },
                ),
                const SizedBox(width: 4),
                // Next Day Button
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: SystemColors.cyanGlow, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Next Day',
                  onPressed: () {
                    widget.state.selectDate(selectedDate.add(const Duration(days: 1)));
                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Horizontal Date Strip
          SizedBox(
            height: 76,
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              itemCount: dates.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final date = dates[index];
                final isSelected = date.year == selectedDate.year &&
                    date.month == selectedDate.month &&
                    date.day == selectedDate.day;
                final isDateToday = widget.state.isDateToday(date);
                final completionRatio = widget.state.getDateCompletionRatio(date);
                final completedCount = widget.state.getDateCompletedCount(date);
                final totalCount = widget.state.getDateTotalCount(date);

                return GestureDetector(
                  onTap: () {
                    widget.state.selectDate(date);
                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _itemWidth,
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? SystemColors.cyanGlow.withValues(alpha: 0.22)
                          : Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: isSelected
                            ? SystemColors.cyanGlow
                            : (isDateToday
                                ? SystemColors.cyanGlow.withValues(alpha: 0.5)
                                : Colors.white12),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: SystemColors.cyanGlow.withValues(alpha: 0.35),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Weekday text
                        Text(
                          _getWeekdayName(date.weekday),
                          style: GoogleFonts.rajdhani(
                            color: isSelected
                                ? SystemColors.cyanGlow
                                : (isDateToday ? Colors.white : Colors.white54),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Day Number
                        Text(
                          '${date.day}',
                          style: GoogleFonts.orbitron(
                            color: isSelected
                                ? Colors.white
                                : (isDateToday ? SystemColors.cyanGlow : Colors.white70),
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Completion indicator dot / status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (completionRatio == 1.0 && totalCount > 0)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: SystemColors.hpGreen,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: SystemColors.hpGreen,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              )
                            else if (completedCount > 0)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: SystemColors.cyanGlow.withValues(alpha: 0.8),
                                  shape: BoxShape.circle,
                                ),
                              )
                            else
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: isSelected ? SystemColors.cyanGlow.withValues(alpha: 0.4) : Colors.white24,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
