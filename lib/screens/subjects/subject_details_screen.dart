import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../themes/palette.dart';
import '../../models/attendx_model.dart';
import '../../models/subject.dart';
import '../../widgets/common.dart';
import '../today/mark_attendance_screen.dart'; // For ProgressRing
import 'add_edit_subject_screen.dart';

class SubjectDetailsScreen extends StatefulWidget {
  const SubjectDetailsScreen({super.key, required this.subject});

  final Subject subject;

  @override
  State<SubjectDetailsScreen> createState() => _SubjectDetailsScreenState();
}

class _SubjectDetailsScreenState extends State<SubjectDetailsScreen> {
  String _selectedFilter = 'all'; // 'all', 'present', 'absent', 'off'

  String _formatDate(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final model = AttendXScope.of(context);
    final subject = model.subjects.firstWhere(
      (s) => s.code == widget.subject.code || s.name == widget.subject.name,
      orElse: () => widget.subject,
    );

    // Extract all date records specific to this subject
    final subjectRecords = <_SubjectDayRecord>[];
    for (final entry in model.dailyRecords.entries) {
      final status = entry.value[subject.name];
      if (status != null && status.isNotEmpty && status != 'clear') {
        DateTime? dt;
        try {
          dt = DateTime.parse(entry.key);
        } catch (_) {}
        if (dt != null) {
          subjectRecords.add(_SubjectDayRecord(date: dt, status: status, dateKey: entry.key));
        }
      }
    }
    // Sort latest date first
    subjectRecords.sort((a, b) => b.date.compareTo(a.date));

    final presentCount = subjectRecords.where((r) => r.status == 'present').length;
    final absentCount = subjectRecords.where((r) => r.status == 'absent').length;
    final offCount = subjectRecords.where((r) => r.status == 'off').length;

    final filteredRecords = _selectedFilter == 'all'
        ? subjectRecords
        : subjectRecords.where((r) => r.status == _selectedFilter).toList();

    return GradientScaffold(
      child: SafeArea(
        child: PageFrame(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 34),
          children: [
            TopBar(showBack: true, title: subject.name),
            GlassCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  SubjectIcon(subject: subject, size: 78),
                  const SizedBox(height: 14),
                  Text(
                    subject.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  if (subject.code.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      subject.code,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.58),
                          ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  ProgressRing(
                    value: subject.percentage / 100,
                    label: '${subject.percentage.round()}%',
                    color: subject.statusColor,
                    size: 132,
                    strokeWidth: 13,
                  ),
                  const SizedBox(height: 16),
                  StatusPill(label: subject.statusLabel, color: subject.statusColor),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: StatGlassTile(
                    title: 'Present',
                    value: '${subject.present}',
                    icon: CupertinoIcons.check_mark_circled,
                    color: AppPalette.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatGlassTile(
                    title: 'Absent',
                    value: '${subject.total - subject.present}',
                    icon: CupertinoIcons.xmark_circle,
                    color: AppPalette.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatGlassTile(
                    title: 'Total',
                    value: '${subject.total}',
                    icon: CupertinoIcons.calendar,
                    color: AppPalette.blue,
                  ),
                ),
              ],
            ),
            // Daily Attendance History specifically for this Subject
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SectionHeader(title: 'Attendance History'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: model.themePalette.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: model.themePalette.accent.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '${subjectRecords.length} Classes',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: model.themePalette.accent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All (${subjectRecords.length})',
                          isSelected: _selectedFilter == 'all',
                          color: model.themePalette.isDark ? model.themePalette.accent : AppPalette.ink,
                          onTap: () => setState(() => _selectedFilter = 'all'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Present ($presentCount)',
                          isSelected: _selectedFilter == 'present',
                          color: model.themePalette.isDark ? model.themePalette.accent : AppPalette.green,
                          onTap: () => setState(() => _selectedFilter = 'present'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Absent ($absentCount)',
                          isSelected: _selectedFilter == 'absent',
                          color: AppPalette.red,
                          onTap: () => setState(() => _selectedFilter = 'absent'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'No Class ($offCount)',
                          isSelected: _selectedFilter == 'off',
                          color: AppPalette.yellow,
                          onTap: () => setState(() => _selectedFilter = 'off'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (filteredRecords.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          _selectedFilter == 'all'
                              ? 'No attendance recorded for ${subject.name} yet.'
                              : 'No $_selectedFilter records found.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: model.themePalette.textSecondary),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredRecords.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final record = filteredRecords[index];
                        final isToday = model.dateKey(record.date) == model.dateKey(DateTime.now());

                        Color statusColor;
                        IconData statusIcon;
                        String statusLabel;

                        if (record.status == 'present') {
                          statusColor = model.themePalette.isDark ? model.themePalette.accent : AppPalette.green;
                          statusIcon = CupertinoIcons.check_mark_circled_solid;
                          statusLabel = 'Present';
                        } else if (record.status == 'absent') {
                          statusColor = AppPalette.red;
                          statusIcon = CupertinoIcons.xmark_circle_fill;
                          statusLabel = 'Absent';
                        } else {
                          statusColor = AppPalette.yellow;
                          statusIcon = CupertinoIcons.minus_circle_fill;
                          statusLabel = 'No Class';
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: model.themePalette.isDark ? const Color(0xFF1A1610) : Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isToday ? (model.themePalette.isDark ? model.themePalette.accent : AppPalette.green) : model.themePalette.cardBorder,
                              width: isToday ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(statusIcon, color: statusColor, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          _formatDate(record.date),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: model.themePalette.textPrimary,
                                          ),
                                        ),
                                        if (isToday) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: (model.themePalette.isDark ? model.themePalette.accent : AppPalette.green).withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'Today',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: model.themePalette.isDark ? model.themePalette.accent : AppPalette.green,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'CT Breakdown'),
                  const SizedBox(height: 14),
                  ...model.ctSlices.map(
                    (ct) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TrendRow(
                        label: ct.label,
                        value: '${ct.present}/${ct.total}',
                        percent: ct.percent,
                        color: ct.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AddEditSubjectScreen.route,
                      arguments: subject,
                    ),
                    icon: const Icon(CupertinoIcons.pencil),
                    label: const Text('Edit Subject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showConfirmDialog(
                        context,
                        title: 'Delete Subject?',
                        message: 'Are you sure you want to delete "${subject.name}"? This will permanently remove this subject and all its attendance history.',
                        confirmLabel: 'Delete',
                        isDestructive: true,
                      );
                      if (confirm && context.mounted) {
                        model.deleteSubject(subject);
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(CupertinoIcons.delete, color: AppPalette.red),
                    label: const Text('Delete', style: TextStyle(color: AppPalette.red)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppPalette.red.withValues(alpha: 0.3)),
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
}

class _SubjectDayRecord {
  const _SubjectDayRecord({
    required this.date,
    required this.status,
    required this.dateKey,
  });

  final DateTime date;
  final String status;
  final String dateKey;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BouncyTap(
      scaleDown: 0.94,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? ((color == AppPalette.yellow || (isDark && color == AppPalette.gold)) ? Colors.black : Colors.white)
                : color,
          ),
        ),
      ),
    );
  }
}
