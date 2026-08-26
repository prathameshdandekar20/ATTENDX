import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../themes/palette.dart';
import '../../models/attendx_model.dart';
import '../../models/timetable_entry.dart';
import '../../widgets/common.dart';
import '../today/mark_attendance_screen.dart'; // For TodayClassTile, ProgressRing
import '../subjects/subject_details_screen.dart';
import '../subjects/add_edit_subject_screen.dart';

class TimetableScreen extends StatefulWidget {
  static const route = '/timetable';

  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  int _currentSegment = 0; // 0 = Timetable, 1 = Subjects
  static const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static const _shortDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  late int _selectedDayIndex;

  @override
  void initState() {
    super.initState();
    final weekday = DateTime.now().weekday; // 1=Mon..7=Sun
    _selectedDayIndex = (weekday >= 1 && weekday <= 7) ? weekday - 1 : 0;
  }

  String get _selectedDay => _days[_selectedDayIndex];

  void _showAddClassDialog() {
    final model = AttendXScope.of(context);
    String? selectedSubject = model.subjects.isNotEmpty ? model.subjects.first.name : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Add Class - $_selectedDay'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (model.subjects.isEmpty)
                  const Text('Add subjects first from the Subjects tab.')
                else
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: selectedSubject,
                    decoration: setupDecoration(ctx, 'Subject', CupertinoIcons.book),
                    borderRadius: BorderRadius.circular(20),
                    items: model.subjects.map((s) {
                      return DropdownMenuItem(
                        value: s.name,
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                s.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (s.isLab) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppPalette.purple.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'LAB',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppPalette.purple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setDialogState(() => selectedSubject = v),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: (model.subjects.isEmpty || selectedSubject == null || selectedSubject!.isEmpty)
                  ? null
                  : () {
                      model.addTimetableEntry(
                        _selectedDay,
                        TimetableEntry(
                          subjectName: selectedSubject!,
                        ),
                      );
                      Navigator.pop(ctx);
                    },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = AttendXScope.of(context);
    final daySchedule = model.scheduleForDay(_selectedDay);
    final gap = model.overallAttendance - model.minimumAttendance;

    return PageFrame(
      children: [
        // Top Segmented Pill (Timetable vs Subjects)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: model.themePalette.cardFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: model.themePalette.cardBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: BouncyTap(
                  onTap: () => setState(() => _currentSegment = 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _currentSegment == 0 ? model.themePalette.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.calendar,
                          size: 16,
                          color: _currentSegment == 0
                              ? (model.isDarkTheme ? Colors.black : Colors.white)
                              : model.themePalette.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Timetable',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: _currentSegment == 0
                                ? (model.isDarkTheme ? Colors.black : Colors.white)
                                : model.themePalette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: BouncyTap(
                  onTap: () => setState(() => _currentSegment = 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _currentSegment == 1 ? model.themePalette.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.book,
                          size: 16,
                          color: _currentSegment == 1
                              ? (model.isDarkTheme ? Colors.black : Colors.white)
                              : model.themePalette.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Subjects',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: _currentSegment == 1
                                ? (model.isDarkTheme ? Colors.black : Colors.white)
                                : model.themePalette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // === VIEW 1: TIMETABLE VIEW ===
        if (_currentSegment == 0) ...[
          // Day Selector
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                final selected = index == _selectedDayIndex;
                return BouncyTap(
                  onTap: () {
                    AppHaptics.selection();
                    setState(() => _selectedDayIndex = index);
                  },
                  child: GlassCard(
                    radius: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _shortDays[index],
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: selected ? model.themePalette.accent : model.themePalette.textSecondary,
                                fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: selected ? model.themePalette.accent : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: _shortDays.length,
            ),
          ),
          // Classes for selected day
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$_selectedDay Classes',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: model.themePalette.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    BouncyTap(
                      onTap: _showAddClassDialog,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: model.themePalette.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: model.themePalette.accent.withValues(alpha: 0.3)),
                        ),
                        child: Icon(CupertinoIcons.plus, color: model.themePalette.accent, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (daySchedule.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(CupertinoIcons.calendar_badge_plus,
                              color: model.themePalette.textMuted, size: 42),
                          const SizedBox(height: 10),
                          Text(
                            'No classes on $_selectedDay',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: model.themePalette.textSecondary,
                                ),
                          ),
                          const SizedBox(height: 10),
                          FilledButton.icon(
                            onPressed: _showAddClassDialog,
                            icon: const Icon(CupertinoIcons.plus, size: 16),
                            label: const Text('Add Class'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...List.generate(daySchedule.length, (index) {
                    final item = daySchedule[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: ValueKey('${_selectedDay}_${item.subject.name}_${item.time}_$index'),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showConfirmDialog(
                            context,
                            title: 'Remove Class?',
                            message: 'Are you sure you want to remove ${item.subject.name}${item.time.isNotEmpty ? " (${item.time})" : ""} from $_selectedDay\'s schedule?',
                            confirmLabel: 'Remove',
                          );
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppPalette.red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(CupertinoIcons.delete, color: AppPalette.red),
                        ),
                        onDismissed: (_) {
                          model.removeTimetableEntry(_selectedDay, index);
                        },
                        child: TodayClassTile(
                          item: item,
                          dayName: _selectedDay,
                          onDelete: () async {
                            final confirm = await showConfirmDialog(
                              context,
                              title: 'Remove Class?',
                              message: 'Are you sure you want to remove ${item.subject.name}${item.time.isNotEmpty ? " (${item.time})" : ""} from $_selectedDay\'s schedule?',
                              confirmLabel: 'Remove',
                            );
                            if (confirm) {
                              model.removeTimetableEntry(_selectedDay, index);
                            }
                          },
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
          // Weekly overview
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Overview',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: model.themePalette.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 14),
                ..._days.map((day) {
                  final count = (model.weeklyTimetable[day] ?? []).length;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 90,
                          child: Text(
                            day,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: day == _selectedDay ? model.themePalette.accent : model.themePalette.textSecondary,
                                  fontWeight: day == _selectedDay ? FontWeight.w900 : FontWeight.w600,
                                ),
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              minHeight: 8,
                              value: count / 8.0,
                              backgroundColor: model.themePalette.accent.withValues(alpha: 0.12),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                day == _selectedDay ? model.themePalette.accent : model.themePalette.accentSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$count classes',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: model.themePalette.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ]
        // === VIEW 2: SUBJECTS VIEW ===
        else ...[
          // Overall Attendance Summary Card
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                ProgressRing(
                  value: model.overallAttendance / 100,
                  label: '${model.overallAttendance.toStringAsFixed(1)}%',
                  color: model.overallAttendance >= model.minimumAttendance
                      ? (model.isDarkTheme ? model.themePalette.accent : AppPalette.green)
                      : AppPalette.red,
                  size: 86,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Attendance',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: model.themePalette.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        model.totalClasses == 0
                            ? 'Start marking classes to see your live attendance status.'
                            : gap >= 0
                                ? 'Above minimum by ${gap.toStringAsFixed(1)}%.'
                                : 'Below minimum by ${gap.abs().toStringAsFixed(1)}%.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: model.themePalette.textSecondary,
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Subjects Header with + Add Subject Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Subjects (${model.subjects.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: model.themePalette.textPrimary,
                    ),
              ),
              BouncyTap(
                onTap: () => Navigator.pushNamed(context, AddEditSubjectScreen.route),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: model.themePalette.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: model.themePalette.accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.plus, color: model.themePalette.accent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Add Subject',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: model.themePalette.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (model.subjects.isEmpty)
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(CupertinoIcons.book, color: model.themePalette.textMuted, size: 42),
                  const SizedBox(height: 12),
                  Text(
                    'No subjects added',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: model.themePalette.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Create your first subject to begin tracking.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: model.themePalette.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => Navigator.pushNamed(context, AddEditSubjectScreen.route),
                    icon: const Icon(CupertinoIcons.plus, size: 16),
                    label: const Text('Add Subject'),
                  ),
                ],
              ),
            )
          else
            ...model.subjects.map(
              (subject) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: ValueKey('sem_${model.currentSemester}_subj_${subject.name}_${subject.code}_${subject.isLab}'),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showConfirmDialog(
                      context,
                      title: 'Delete Subject?',
                      message: 'Are you sure you want to delete "${subject.name}"? This will permanently remove this subject and all its attendance history.',
                      confirmLabel: 'Delete',
                      isDestructive: true,
                    );
                  },
                  onDismissed: (_) {
                    model.deleteSubject(subject);
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppPalette.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(CupertinoIcons.delete, color: AppPalette.red),
                  ),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubjectDetailsScreen(subject: subject),
                      ),
                    ),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          SubjectIcon(subject: subject, size: 48),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        subject.name,
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (subject.isLab) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppPalette.purple.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'LAB',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppPalette.purple,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${subject.present}/${subject.total} attended • ${subject.canMiss} safe bunks',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppPalette.slate,
                                        fontSize: 11,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ProgressRing(
                                value: subject.percentage / 100,
                                label: '${subject.percentage.round()}%',
                                color: subject.statusColor,
                                size: 46,
                                strokeWidth: 5,
                              ),
                              const SizedBox(height: 4),
                              StatusPill(
                                label: subject.statusLabel,
                                color: subject.statusColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
        const SizedBox(height: 80),
      ],
    );
  }
}

