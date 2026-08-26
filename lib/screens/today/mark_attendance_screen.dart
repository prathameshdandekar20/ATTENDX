import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../themes/palette.dart';
import '../../models/attendx_model.dart';
import '../../models/subject.dart';
import '../../models/timetable_entry.dart';
import '../../widgets/common.dart';
import '../../shell/attendx_shell.dart';
import '../subjects/subject_details_screen.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  String _formatDate(DateTime date) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${dayNames[date.weekday - 1]}, ${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  void _showAddExtraLectureDialog(BuildContext context, AttendXModel model) {
    if (model.subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add subjects first from Schedule.')),
      );
      return;
    }

    Subject selectedSubject = model.subjects.first;
    String? selectedInitialStatus; // null = leave unmarked, 'present', 'absent', 'off'

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: const Text('Add Extra Lecture'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date: ${_formatDate(_selectedDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppPalette.slate,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Subject',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Subject>(
                  isExpanded: true,
                  initialValue: selectedSubject,
                  decoration: setupDecoration(ctx, 'Subject', CupertinoIcons.book),
                  borderRadius: BorderRadius.circular(20),
                  items: model.subjects.map((s) {
                    return DropdownMenuItem<Subject>(
                      value: s,
                      child: Row(
                        children: [
                          SubjectIcon(subject: s, size: 24),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              s.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (s.isLab) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppPalette.purple.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'LAB',
                                style: TextStyle(
                                  fontSize: 9,
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
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedSubject = v);
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Initial Status (Optional)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ChoiceChip(
                      label: const Text('Unmarked'),
                      selected: selectedInitialStatus == null,
                      onSelected: (_) => setDialogState(() => selectedInitialStatus = null),
                      selectedColor: AppPalette.slate.withValues(alpha: 0.2),
                      backgroundColor: Colors.transparent,
                    ),
                    ChoiceChip(
                      label: const Text('Present'),
                      selected: selectedInitialStatus == 'present',
                      onSelected: (_) => setDialogState(() => selectedInitialStatus = 'present'),
                      selectedColor: AppPalette.green.withValues(alpha: 0.2),
                      backgroundColor: Colors.transparent,
                      labelStyle: TextStyle(
                        color: selectedInitialStatus == 'present' ? AppPalette.green : null,
                        fontWeight: selectedInitialStatus == 'present' ? FontWeight.bold : null,
                      ),
                    ),
                    ChoiceChip(
                      label: const Text('Absent'),
                      selected: selectedInitialStatus == 'absent',
                      onSelected: (_) => setDialogState(() => selectedInitialStatus = 'absent'),
                      selectedColor: AppPalette.red.withValues(alpha: 0.2),
                      backgroundColor: Colors.transparent,
                      labelStyle: TextStyle(
                        color: selectedInitialStatus == 'absent' ? AppPalette.red : null,
                        fontWeight: selectedInitialStatus == 'absent' ? FontWeight.bold : null,
                      ),
                    ),
                    ChoiceChip(
                      label: const Text('Cancelled'),
                      selected: selectedInitialStatus == 'off',
                      onSelected: (_) => setDialogState(() => selectedInitialStatus = 'off'),
                      selectedColor: AppPalette.yellow.withValues(alpha: 0.2),
                      backgroundColor: Colors.transparent,
                      labelStyle: TextStyle(
                        color: selectedInitialStatus == 'off' ? AppPalette.yellow : null,
                        fontWeight: selectedInitialStatus == 'off' ? FontWeight.bold : null,
                      ),
                    ),
                  ],
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
              onPressed: () {
                model.addExtraLecture(
                  date: _selectedDate,
                  subject: selectedSubject,
                  initialStatus: selectedInitialStatus,
                );
                Navigator.pop(ctx);
              },
              child: const Text('Add Extra Lecture'),
            ),
          ],
        ),
      ),
    );
  }

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _nextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = AttendXScope.of(context);
    final dayName = model.dayNameForDate(_selectedDate);
    final schedule = model.scheduleForDate(_selectedDate);

    final palette = model.themePalette;

    return PageFrame(
      children: [
        // Top row: date with prev/next arrows + overall stats + add extra lecture
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Previous day button
                    BouncyTap(
                      onTap: _previousDay,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: palette.cardFill,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: palette.cardBorder),
                        ),
                        child: Icon(CupertinoIcons.chevron_left, color: palette.textPrimary, size: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Clickable date text
                    Expanded(
                      child: BouncyTap(
                        onTap: () async {
                          final date = await showDialog<DateTime>(
                            context: context,
                            builder: (ctx) => AttendXCalendarDialog(
                              initialDate: _selectedDate,
                              model: model,
                            ),
                          );
                          if (date != null) setState(() => _selectedDate = date);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          decoration: BoxDecoration(
                            color: palette.cardFill,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: palette.cardBorder.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            _formatDate(_selectedDate),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: palette.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Next day button
                    BouncyTap(
                      onTap: _nextDay,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: palette.cardFill,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: palette.cardBorder),
                        ),
                        child: Icon(CupertinoIcons.chevron_right, color: palette.textPrimary, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                radius: 12,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedPercentageText(
                      percentage: model.overallAttendance,
                      style: TextStyle(
                        color: palette.accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      ' | ${model.minimumAttendance.round()}%',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              BouncyTap(
                onTap: () => _showAddExtraLectureDialog(context, model),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: palette.cardFill,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: palette.cardBorder),
                  ),
                  child: Icon(CupertinoIcons.plus, color: palette.accent, size: 17),
                ),
              ),
            ],
          ),
        ),
        // Colored accent bar
        Container(
          height: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              colors: [
                palette.accent.withValues(alpha: 0.8),
                palette.accent.withValues(alpha: 0.15),
              ],
            ),
          ),
        ),
        _DayStatusCard(date: _selectedDate, scheduledItems: schedule),
        const SizedBox(height: 8),
        if (schedule.isEmpty)
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(CupertinoIcons.calendar, color: palette.textMuted, size: 42),
                const SizedBox(height: 12),
                Text('No lectures or labs scheduled',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: palette.textPrimary)),
                const SizedBox(height: 6),
                Text('You do not have any classes scheduled for $dayName.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: palette.textSecondary)),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => _showAddExtraLectureDialog(context, model),
                  icon: const Icon(CupertinoIcons.plus, size: 16),
                  label: const Text('Add Extra Lecture'),
                ),
              ],
            ),
          )
        else
          ...schedule.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _SubjectCard(item: item, model: model, markDate: _selectedDate),
            ),
          ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _DayStatusCard extends StatelessWidget {
  const _DayStatusCard({required this.date, required this.scheduledItems});
  final DateTime date;
  final List<ScheduleItem> scheduledItems;

  @override
  Widget build(BuildContext context) {
    final model = AttendXScope.of(context);
    final palette = model.themePalette;
    final key = model.dateKey(date);
    final records = model.dailyRecords[key] ?? {};

    final scheduledKeys = scheduledItems.map((item) => item.subject.name).toSet();

    String statusText = 'Not marked';
    Color statusColor = palette.textMuted;
    String? masterAction;

    if (scheduledKeys.isNotEmpty) {
      final relevantRecords = records.entries.where((e) => scheduledKeys.contains(e.key)).toList();
      if (relevantRecords.length == scheduledKeys.length) {
        if (relevantRecords.every((e) => e.value == 'present')) {
          statusText = 'Present';
          statusColor = palette.isDark ? palette.accent : AppPalette.green;
          masterAction = 'present';
        } else if (relevantRecords.every((e) => e.value == 'absent')) {
          statusText = 'Absent';
          statusColor = AppPalette.red;
          masterAction = 'absent';
        } else if (relevantRecords.every((e) => e.value == 'off')) {
          statusText = 'Cancelled';
          statusColor = AppPalette.yellow;
          masterAction = 'off';
        } else {
          statusText = 'Mixed';
          statusColor = AppPalette.purple;
        }
      }
    }

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Status indicator dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day status:',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: palette.textSecondary,
                      ),
                ),
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          _DayActionButton(
            icon: Icons.block,
            label: 'Clear',
            onTap: () => model.markAllAttendance('clear', date, targetItems: scheduledItems),
          ),
          const SizedBox(width: 6),
          _DayActionButton(
            icon: Icons.remove_circle_outline,
            label: 'Off',
            color: masterAction == 'off' ? AppPalette.yellow : null,
            onTap: () => model.markAllAttendance('off', date, targetItems: scheduledItems),
          ),
          const SizedBox(width: 6),
          _DayActionButton(
            icon: Icons.close,
            label: 'Miss',
            color: masterAction == 'absent' ? AppPalette.red : null,
            onTap: () => model.markAllAttendance('absent', date, targetItems: scheduledItems),
          ),
          const SizedBox(width: 6),
          _DayActionButton(
            icon: Icons.check_circle,
            label: 'Att',
            color: masterAction == 'present' ? (palette.isDark ? palette.accent : AppPalette.green) : null,
            onTap: () => model.markAllAttendance('present', date, targetItems: scheduledItems),
          ),
        ],
      ),
    );
  }
}

class _DayActionButton extends StatelessWidget {
  const _DayActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final model = AttendXScope.of(context);
    final palette = model.themePalette;
    final c = color ?? palette.textMuted;

    return BouncyTap(
      scaleDown: 0.88,
      onTap: () {
        AppHaptics.selection();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: c, size: 22),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: c,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatefulWidget {
  const _SubjectCard({
    required this.item,
    required this.model,
    required this.markDate,
  });

  final ScheduleItem item;
  final AttendXModel model;
  final DateTime markDate;

  @override
  State<_SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<_SubjectCard> {
  void _markAction(String action) {
    final currentAction = widget.model.getActionForDate(widget.item.subject, widget.markDate);

    if (currentAction == action) {
      AppHaptics.selection();
      // Toggle off
      int pDelta = 0;
      int tDelta = 0;
      if (action == 'present') { pDelta = -1; tDelta = -1; }
      else if (action == 'absent') { pDelta = 0; tDelta = -1; }

      if (pDelta != 0 || tDelta != 0) {
        widget.model.adjustAttendance(widget.item.subject, presentDelta: pDelta, totalDelta: tDelta, action: 'clear', date: widget.markDate);
      } else {
        widget.model.adjustAttendance(widget.item.subject, presentDelta: 0, totalDelta: 0, action: 'clear', date: widget.markDate);
      }
      return;
    }

    if (action == 'present') {
      AppHaptics.light();
    } else if (action == 'absent') {
      AppHaptics.medium();
    } else {
      AppHaptics.selection();
    }

    int pDelta = 0;
    int tDelta = 0;

    if (currentAction == 'present') { pDelta -= 1; tDelta -= 1; }
    else if (currentAction == 'absent') { tDelta -= 1; }

    if (action == 'present') { pDelta += 1; tDelta += 1; }
    else if (action == 'absent') { tDelta += 1; }

    String? logNote;
    bool? logPresent;
    if (action == 'present') {
      logNote = '${widget.item.subject.name} marked present';
      logPresent = true;
    } else if (action == 'absent') {
      logNote = '${widget.item.subject.name} marked absent';
      logPresent = false;
    } else if (action == 'off') {
      logNote = '${widget.item.subject.name} class cancelled';
      logPresent = false;
    }

    widget.model.adjustAttendance(
      widget.item.subject,
      presentDelta: pDelta,
      totalDelta: tDelta,
      action: action,
      date: widget.markDate,
      logNote: logNote,
      logPresent: logPresent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final subject = widget.item.subject;
    final canMiss = subject.canMissFor(widget.model.minimumAttendance);
    final currentAction = widget.model.getActionForDate(subject, widget.markDate);
    final missText = canMiss <= 0
        ? "can't miss the next class"
        : 'can miss $canMiss class${canMiss > 1 ? 'es' : ''}';

    return RunningTrailBorder(
      trailColor: subject.color,
      borderRadius: 28.0,
      strokeWidth: 2.0,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Percentage display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: subject.statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: subject.statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        subject.percentage.toStringAsFixed(2),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: subject.statusColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                      ),
                      Container(
                        width: 28,
                        height: 1,
                        color: subject.statusColor.withValues(alpha: 0.4),
                        margin: const EdgeInsets.symmetric(vertical: 2),
                      ),
                      Text(
                        '${subject.present}/${subject.total}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: subject.statusColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              subject.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.item.isExtra) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: widget.model.themePalette.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: widget.model.themePalette.accent.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                'EXTRA',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: widget.model.themePalette.accent,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        missText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: widget.model.themePalette.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (widget.item.isExtra)
                  BouncyTap(
                    onTap: () {
                      AppHaptics.medium();
                      widget.model.removeExtraLecture(
                        date: widget.markDate,
                        subject: subject,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppPalette.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(CupertinoIcons.delete, size: 12, color: AppPalette.red),
                          SizedBox(width: 4),
                          Text(
                            'Remove',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppPalette.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const Spacer(),
                _SubjectActionIcon(
                  icon: Icons.remove_circle_outline,
                  isSelected: currentAction == 'off',
                  color: currentAction == 'off' ? AppPalette.yellow : null,
                  onTap: () => _markAction('off'),
                ),
                const SizedBox(width: 12),
                _SubjectActionIcon(
                  icon: Icons.close,
                  isSelected: currentAction == 'absent',
                  color: currentAction == 'absent' ? AppPalette.red : null,
                  onTap: () => _markAction('absent'),
                ),
                const SizedBox(width: 12),
                _SubjectActionIcon(
                  icon: Icons.check_circle,
                  isSelected: currentAction == 'present',
                  color: currentAction == 'present' ? (widget.model.isDarkTheme ? widget.model.themePalette.accent : AppPalette.green) : null,
                  isCheckmark: true,
                  onTap: () => _markAction('present'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectActionIcon extends StatelessWidget {
  const _SubjectActionIcon({
    required this.icon,
    required this.onTap,
    this.isSelected = false,
    this.color,
    this.isCheckmark = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;
  final Color? color;
  final bool isCheckmark;

  @override
  Widget build(BuildContext context) {
    final model = AttendXScope.of(context);
    final palette = model.themePalette;
    final c = color ?? (isSelected ? palette.textPrimary : palette.textMuted);

    return BouncyTap(
      scaleDown: 0.88,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isSelected
              ? c.withValues(alpha: 0.18)
              : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? c.withValues(alpha: 0.6) : palette.cardBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: c.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Icon(icon, color: c, size: 20),
      ),
    );
  }
}

class SemesterSummaryCard extends StatelessWidget {
  const SemesterSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final model = AttendXScope.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Semester',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Semester ${model.currentSemester}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(CupertinoIcons.chevron_down, size: 18),
                      ],
                    ),
                  ],
                ),
              ),
              GlassCard(
                radius: 22,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.calendar,
                        color: AppPalette.green, size: 18),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.55),
                                  ),
                        ),
                        Text(
                          shortDate(model.today),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 330;
              final metrics = [
                MetricData(
                  CupertinoIcons.calendar,
                  'Total',
                  '${model.totalClasses}',
                  AppPalette.green,
                ),
                MetricData(
                  CupertinoIcons.check_mark_circled,
                  'Attended',
                  '${model.attendedClasses}',
                  AppPalette.green,
                ),
                MetricData(
                  CupertinoIcons.xmark_circle,
                  'Missed',
                  '${model.missedClasses}',
                  AppPalette.red,
                ),
                MetricData(
                  CupertinoIcons.percent,
                  'Overall',
                  '${model.overallAttendance.toStringAsFixed(1)}%',
                  AppPalette.purple,
                ),
              ];
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: compact ? 2 : 4,
                childAspectRatio: compact ? 2.1 : 0.82,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: metrics
                    .map(
                      (metric) => MetricTile(metric: metric),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class TodayClassTile extends StatelessWidget {
  const TodayClassTile({
    super.key,
    required this.item,
    this.markDate,
    this.dayName,
    this.onDelete,
  });

  final ScheduleItem item;
  final DateTime? markDate;
  final String? dayName;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final model = AttendXScope.of(context);
    final palette = model.themePalette;

    return BouncyTap(
      child: RunningTrailBorder(
        trailColor: item.subject.color,
        borderRadius: 22.0,
        strokeWidth: 1.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: palette.isDark ? const Color(0xFF18140D) : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: palette.isDark
                  ? item.subject.color.withValues(alpha: 0.35)
                  : palette.cardBorder,
              width: 1.0,
            ),
            boxShadow: [
              if (palette.isDark)
                BoxShadow(
                  color: item.subject.color.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              SubjectIcon(subject: item.subject, size: 44),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.subject.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: palette.textPrimary,
                                ),
                          ),
                        ),
                        if (item.isExtra || item.subject.isLab) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (item.isExtra ? palette.accent : AppPalette.purple).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: (item.isExtra ? palette.accent : AppPalette.purple).withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              item.isExtra ? 'EXTRA' : 'LAB',
                              style: TextStyle(
                                fontSize: 10,
                                color: item.isExtra ? palette.accent : AppPalette.purple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (item.time.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.time,
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              BouncyTap(
                onTap: () async {
                  AppHaptics.medium();
                  if (onDelete != null) {
                    onDelete!();
                  } else {
                    final confirm = await showConfirmDialog(
                      context,
                      title: 'Remove Class?',
                      message: 'Are you sure you want to remove ${item.subject.name}${item.time.isNotEmpty ? " (${item.time})" : ""} from the schedule?',
                      confirmLabel: 'Remove',
                    );
                    if (confirm && context.mounted) {
                      final model = AttendXScope.of(context);
                      final targetDay = dayName ?? (markDate != null ? model.dayNameForDate(markDate!) : model.todayDayName);
                      model.removeTimetableItem(targetDay, TimetableEntry(subjectName: item.subject.name, time: item.time, room: item.room));
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppPalette.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(CupertinoIcons.delete, color: AppPalette.red, size: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AttendanceButton extends StatelessWidget {
  const AttendanceButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isSelected = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 12,
          vertical: isSelected ? 12 : 10,
        ),
        constraints: const BoxConstraints(minWidth: 100),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isSelected ? 0.32 : 0.12),
              blurRadius: isSelected ? 24 : 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: isSelected ? 20 : 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected ? Colors.white : color,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class IconLabel extends StatelessWidget {
  const IconLabel({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.52),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.62),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

class SubjectMarkCard extends StatelessWidget {
  const SubjectMarkCard({super.key, required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () => Navigator.push(
        context,
        PremiumRoute(child: SubjectDetailsScreen(subject: subject)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SubjectIcon(subject: subject, size: 60),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${subject.present} / ${subject.total} classes attended',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.58),
                      ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: subject.percentage / 100,
                    backgroundColor: subject.statusColor.withValues(alpha: 0.12),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(subject.statusColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          ProgressRing(
            value: subject.percentage / 100,
            label: '${subject.percentage.round()}%',
            color: subject.statusColor,
            size: 62,
          ),
        ],
      ),
    );
  }
}

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      QuickAction(
        'Statistics',
        'View reports',
        Icons.pie_chart_rounded,
        AppPalette.purple,
        () => Navigator.pushNamed(context, '/statistics'),
      ),
      QuickAction(
        'Bunk Calculator',
        'Plan smart',
        Icons.calculate_rounded,
        AppPalette.yellow,
        () {
          final shell = AttendXShellScope.maybeOf(context);
          if (shell != null) {
            shell.switchToTab(3);
          } else {
            Navigator.pushNamed(context, '/bunk-calculator');
          }
        },
      ),
      QuickAction(
        'Export Excel',
        'Download report',
        Icons.table_chart_rounded,
        AppPalette.green,
        () => Navigator.pushNamed(context, '/excel-export'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Quick Actions'),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 360 ? 2 : 4;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: columns == 2 ? 1.45 : 0.88,
              children:
                  actions.map((action) => QuickActionCard(action: action)).toList(),
            );
          },
        ),
      ],
    );
  }
}

class QuickAction {
  const QuickAction(this.title, this.subtitle, this.icon, this.color, this.onTap);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({super.key, required this.action});

  final QuickAction action;

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      onTap: action.onTap,
      child: GlassCard(
        radius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(action.icon, color: action.color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              action.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              action.subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.56),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendXCalendarDialog extends StatefulWidget {
  const AttendXCalendarDialog({super.key, required this.initialDate, required this.model});
  final DateTime initialDate;
  final AttendXModel model;

  @override
  State<AttendXCalendarDialog> createState() => _AttendXCalendarDialogState();
}

class _AttendXCalendarDialogState extends State<AttendXCalendarDialog> {
  late DateTime _viewMonth;

  @override
  void initState() {
    super.initState();
    _viewMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  void _prevMonth() => setState(() => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1));
  void _nextMonth() => setState(() => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1));

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 0).day;
    final firstDayWeekday = DateTime(_viewMonth.year, _viewMonth.month, 1).weekday;
    // Adjust for Monday start (Flutter weekday: 1=Mon, 7=Sun)
    final offset = firstDayWeekday - 1;

    final monthName = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ][_viewMonth.month - 1];

    final palette = widget.model.themePalette;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: palette.isDark ? const Color(0xFF16130E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: palette.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _prevMonth,
                    icon: Icon(CupertinoIcons.left_chevron, size: 20, color: palette.textPrimary),
                  ),
                  Text(
                    '$monthName ${_viewMonth.year}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  IconButton(
                    onPressed: _nextMonth,
                    icon: Icon(CupertinoIcons.right_chevron, size: 20, color: palette.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Weekday headers
              Row(
                children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: palette.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 8),
              // Calendar grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemCount: 42, // 6 rows
                itemBuilder: (ctx, index) {
                  final dayNum = index - offset + 1;
                  if (dayNum < 1 || dayNum > daysInMonth) return const SizedBox();

                  final date = DateTime(_viewMonth.year, _viewMonth.month, dayNum);
                  final statusColor = widget.model.getDayColor(date);
                  final isToday = widget.model.dateKey(date) == widget.model.dateKey(DateTime.now());
                  final isSelected = widget.model.dateKey(date) == widget.model.dateKey(widget.initialDate);

                  return GestureDetector(
                    onTap: () => Navigator.pop(context, date),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? palette.accent
                            : (palette.isDark ? const Color(0xFF221E17) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(10),
                        border: isToday
                            ? Border.all(color: palette.accent, width: 2)
                            : Border.all(color: palette.cardBorder.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNum',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isSelected
                                      ? (palette.isDark ? Colors.black : Colors.white)
                                      : palette.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                          ),
                          if (statusColor != Colors.transparent) ...[
                            const SizedBox(height: 2),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (palette.isDark ? Colors.black : Colors.white)
                                    : statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Legend
              Wrap(
                spacing: 12,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  _LegendItem(color: AppPalette.green, label: 'Present'),
                  _LegendItem(color: AppPalette.red, label: 'Absent'),
                  _LegendItem(color: AppPalette.purple, label: 'Mixed'),
                  _LegendItem(color: AppPalette.yellow, label: 'Holiday'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppPalette.slate)),
      ],
    );
  }
}

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    this.size = 58,
    this.strokeWidth,
  });

  final double value;
  final String label;
  final Color color;
  final double size;
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    final effectiveStroke = strokeWidth ?? (size * 0.085).clamp(4.0, 12.0);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _ProgressRingPainter(
                    progress: animatedValue,
                    color: color,
                    strokeWidth: effectiveStroke,
                    backgroundColor: color.withValues(alpha: 0.14),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(effectiveStroke + 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w900,
                          fontSize: size * 0.24,
                        ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  const _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    if (radius <= 0) return;

    // Background track
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc with glow
    if (progress > 0) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0)
        ..strokeCap = StrokeCap.round;

      final fgPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;
      final rect = Rect.fromCircle(center: center, radius: radius);

      canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);
      canvas.drawArc(rect, startAngle, sweepAngle, false, fgPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
