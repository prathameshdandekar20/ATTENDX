import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../themes/palette.dart';
import '../../models/attendx_model.dart';
import '../../widgets/common.dart';

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  late DateTime _currentMonth;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final model = AttendXScope.of(context);
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];

    final palette = model.themePalette;

    return PageFrame(
      children: [
        // Month navigation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              BouncyTap(
                onTap: () {
                  setState(() {
                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                  });
                },
                child: Icon(CupertinoIcons.chevron_left, color: palette.textPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              BouncyTap(
                onTap: () {
                  setState(() {
                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                  });
                },
                child: Icon(CupertinoIcons.chevron_right, color: palette.textPrimary, size: 20),
              ),
            ],
          ),
        ),
        // Calendar grid
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Weekday headers
              Row(
                children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: palette.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              // Day cells
              ...List.generate(6, (week) {
                return Row(
                  children: List.generate(7, (weekday) {
                    final dayIndex = week * 7 + weekday - (firstWeekday - 1);
                    if (dayIndex < 1 || dayIndex > daysInMonth) {
                      return const Expanded(child: SizedBox(height: 40));
                    }
                    final date = DateTime(_currentMonth.year, _currentMonth.month, dayIndex);
                    final isToday = date.year == DateTime.now().year &&
                        date.month == DateTime.now().month &&
                        date.day == DateTime.now().day;
                    final isSelected = _selectedDay != null &&
                        date.year == _selectedDay!.year &&
                        date.month == _selectedDay!.month &&
                        date.day == _selectedDay!.day;

                    // Check daily records for this date
                    final dayKey = model.dateKey(date);
                    final dayRecords = model.dailyRecords[dayKey] ?? {};
                    final hasRecords = dayRecords.isNotEmpty;

                    Color dotColor = Colors.transparent;
                    if (hasRecords) {
                      final values = dayRecords.values.toList();
                      if (values.every((a) => a == 'present')) {
                        dotColor = palette.isDark ? palette.accent : AppPalette.green;
                      } else if (values.every((a) => a == 'absent')) {
                        dotColor = AppPalette.red;
                      } else if (values.every((a) => a == 'off')) {
                        dotColor = AppPalette.yellow;
                      } else {
                        dotColor = AppPalette.purple;
                      }
                    }

                    return Expanded(
                      child: BouncyTap(
                        scaleDown: 0.9,
                        onTap: () => setState(() => _selectedDay = date),
                        child: Container(
                          height: 40,
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? palette.accent.withValues(alpha: 0.2)
                                : isToday
                                    ? (palette.isDark ? const Color(0xFF221E17) : AppPalette.glassLine)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected
                                ? Border.all(color: palette.accent, width: 1.5)
                                : isToday
                                    ? Border.all(color: palette.accent.withValues(alpha: 0.5), width: 1)
                                    : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$dayIndex',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: isSelected
                                          ? palette.accent
                                          : isToday
                                              ? palette.textPrimary
                                              : palette.textSecondary,
                                      fontWeight: isSelected || isToday
                                          ? FontWeight.w800
                                          : FontWeight.w500,
                                    ),
                              ),
                              if (hasRecords)
                                Container(
                                  width: 4,
                                  height: 4,
                                  margin: const EdgeInsets.only(top: 2),
                                  decoration: BoxDecoration(
                                    color: dotColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                );
              }),
            ],
          ),
        ),
        // Attendance logs for selected day
        if (_selectedDay != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              'Logs for ${shortDate(_selectedDay!)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          ...model.logs
              .where((l) => l.date == fullDate(_selectedDay!))
              .map((log) => GlassCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: log.present
                                ? (palette.isDark ? palette.accent : AppPalette.green).withValues(alpha: 0.15)
                                : AppPalette.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            log.present
                                ? CupertinoIcons.check_mark
                                : CupertinoIcons.xmark,
                            color: log.present ? (palette.isDark ? palette.accent : AppPalette.green) : AppPalette.red,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            log.note,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: palette.textPrimary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  )),
          if (model.logs.where((l) => l.date == fullDate(_selectedDay!)).isEmpty)
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No attendance marked for this day.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.textSecondary,
                    ),
              ),
            ),
        ],
        const SizedBox(height: 80),
      ],
    );
  }
}
