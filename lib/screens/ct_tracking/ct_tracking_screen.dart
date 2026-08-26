import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../themes/palette.dart';
import '../../models/attendx_model.dart';
import '../../widgets/common.dart';
import '../today/mark_attendance_screen.dart'; // For AttendXCalendarDialog

class CtTrackingScreen extends StatelessWidget {
  static const route = '/ct-tracking';

  const CtTrackingScreen({super.key});

  String _monthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final model = AttendXScope.of(context);
    final ct1Done = model.ct1CompletedDate != null;

    final slices = model.ctSlices;

    return PageFrame(
      children: [
        const HeroTitle(
          eyebrow: 'Track attendance windows between class tests',
          title: 'Breakdown',
        ),
        // Rings horizontally
        GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SectionHeader(title: 'Active Attendance Windows'),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const ClampingScrollPhysics(),
                child: Row(
                  children: slices.where((s) => s.label == 'Overall' || s.label.startsWith('After')).map((slice) {
                    return Container(
                      width: 170,
                      height: 250,
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        color: model.themePalette.cardFill,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: slice.color.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            slice.label == 'Overall' ? 'Overall Attendance' : slice.label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: slice.color,
                                ),
                          ),
                          const SizedBox(height: 16),
                          ProgressRing(
                            value: slice.percent.clamp(0.0, 1.0),
                            label: '${(slice.percent * 100).toStringAsFixed(1)}%',
                            color: slice.color,
                            size: 100,
                          ),
                          const SizedBox(height: 16),
                          const Spacer(),
                          Text(
                            '${slice.present}/${slice.total} classes',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: model.themePalette.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        // Combined Lab Attendance
        GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SectionHeader(title: 'Overall with Labs'),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    ProgressRing(
                      value: model.combinedOverallAttendance / 100,
                      label: '${model.combinedOverallAttendance.toStringAsFixed(1)}%',
                      color: model.combinedOverallAttendance >= model.minimumAttendance
                          ? AppPalette.green
                          : AppPalette.red,
                      size: 80,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lectures + Labs',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${model.combinedAttendedClasses}/${model.combinedTotalClasses} total attended',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppPalette.slate,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Min required: ${model.minimumAttendance.round()}%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppPalette.slate,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Mark CT Completion'),
              const SizedBox(height: 12),
              Text(
                'When your class test is over, mark it completed. A new attendance counter will start tracking from this point onward, running in parallel with your overall attendance.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppPalette.slate),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ct1Done
                        ? FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppPalette.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) {
                                  DateTime currentDate = DateTime.now();
                                  if (model.ct1CompletedDate != null) {
                                    try {
                                      currentDate = DateTime.parse(model.ct1CompletedDate!);
                                    } catch (_) {}
                                  }
                                  DateTime selectedDate = currentDate;

                                  return StatefulBuilder(
                                    builder: (dialogCtx, setDialogState) {
                                      final snapshot = model.calculateSnapshotAt(selectedDate);
                                      final dateStr = '${selectedDate.day} ${_monthName(selectedDate.month)} ${selectedDate.year}';
                                      final hasDateChanged = model.dateKey(selectedDate) != model.ct1CompletedDate;

                                      return AlertDialog(
                                        title: const Text('Manage CT1 Completion'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'You can change the CT1 completion date or undo the completion entirely.',
                                              style: TextStyle(fontSize: 13, color: AppPalette.slate),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Completion Date:',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            const SizedBox(height: 8),
                                            InkWell(
                                              onTap: () async {
                                                final date = await showDialog<DateTime>(
                                                  context: context,
                                                  builder: (ctx) => AttendXCalendarDialog(
                                                    initialDate: selectedDate,
                                                    model: model,
                                                  ),
                                                );
                                                if (date != null) {
                                                  setDialogState(() {
                                                    selectedDate = date;
                                                  });
                                                }
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: model.themePalette.isDark ? const Color(0xFF1E1A14) : Colors.black.withValues(alpha: 0.05),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: model.themePalette.cardBorder),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(CupertinoIcons.calendar, size: 18, color: model.themePalette.accent),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      dateStr,
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: model.themePalette.textPrimary,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Icon(CupertinoIcons.chevron_down, size: 14, color: model.themePalette.textSecondary),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Snapshot for selected date:',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '${snapshot['present']}/${snapshot['total']} classes attended',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppPalette.green,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text('Cancel'),
                                          ),
                                          OutlinedButton(
                                            onPressed: () {
                                              model.undoCT1();
                                              Navigator.pop(ctx);
                                            },
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppPalette.red,
                                              side: BorderSide(color: AppPalette.red.withValues(alpha: 0.5)),
                                            ),
                                            child: const Text('Undo Completion'),
                                          ),
                                          FilledButton(
                                            onPressed: hasDateChanged
                                                ? () {
                                                    model.completeCT1At(selectedDate);
                                                    Navigator.pop(ctx);
                                                  }
                                                : null,
                                            child: const Text('Save Changes'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            icon: const Icon(CupertinoIcons.check_mark_circled, size: 18),
                            label: Text('CT1 Done (${model.ct1CompletedDate})'),
                          )
                        : FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppPalette.slate,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) {
                                  DateTime selectedDate = DateTime.now();
                                  return StatefulBuilder(
                                    builder: (dialogCtx, setDialogState) {
                                      final snapshot = model.calculateSnapshotAt(selectedDate);
                                      final dateStr = '${selectedDate.day} ${_monthName(selectedDate.month)} ${selectedDate.year}';

                                      return AlertDialog(
                                        title: const Text('Complete CT1?'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Select the date CT1 was completed. A new attendance counter will start tracking after this date.',
                                              style: TextStyle(fontSize: 13, color: AppPalette.slate),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Completion Date:',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            const SizedBox(height: 8),
                                            InkWell(
                                              onTap: () async {
                                                final date = await showDialog<DateTime>(
                                                  context: context,
                                                  builder: (ctx) => AttendXCalendarDialog(
                                                    initialDate: selectedDate,
                                                    model: model,
                                                  ),
                                                );
                                                if (date != null) {
                                                  setDialogState(() {
                                                    selectedDate = date;
                                                  });
                                                }
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: model.themePalette.isDark ? const Color(0xFF1E1A14) : Colors.black.withValues(alpha: 0.05),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: model.themePalette.cardBorder),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(CupertinoIcons.calendar, size: 18, color: model.themePalette.accent),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      dateStr,
                                                      style: TextStyle(fontWeight: FontWeight.bold, color: model.themePalette.textPrimary),
                                                    ),
                                                    const Spacer(),
                                                    Icon(CupertinoIcons.chevron_down, size: 14, color: model.themePalette.textSecondary),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Calculated Snapshot:',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '${snapshot['present']}/${snapshot['total']} classes attended',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppPalette.green,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'An "After CT1" attendance tracker will start recording from this date.',
                                              style: TextStyle(fontSize: 11, color: AppPalette.slate),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text('Cancel'),
                                          ),
                                          FilledButton(
                                            onPressed: () {
                                              model.completeCT1At(selectedDate);
                                              Navigator.pop(ctx);
                                            },
                                            child: const Text('Confirm'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            icon: const Icon(CupertinoIcons.circle, size: 18),
                            label: const Text('CT1 Completed'),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // CT Attendance Breakdown
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Attendance Breakdown'),
              const SizedBox(height: 16),
              ...model.ctSlices.map(
                (ct) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              ct.label,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          Text(
                            '${ct.present}/${ct.total}',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: ct.color,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            ct.total == 0 ? '0%' : '${(ct.percent * 100).toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppPalette.slate,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: ct.percent.clamp(0.0, 1.0),
                          backgroundColor: ct.color.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(ct.color),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Reset button
        if (ct1Done)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Reset CT Tracking?'),
                    content: const Text(
                      'This will clear all CT milestones and snapshots. Your actual attendance data remains unchanged.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () {
                          model.resetCTTracking();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(CupertinoIcons.refresh, size: 16),
              label: const Text('Reset CT Tracking'),
            ),
          ),
        const SizedBox(height: 80),
      ],
    );
  }
}
