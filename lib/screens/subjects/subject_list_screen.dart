import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../themes/palette.dart';
import '../../models/attendx_model.dart';
import '../../models/subject.dart';
import '../../widgets/common.dart';
import '../today/mark_attendance_screen.dart'; // For ProgressRing
import 'subject_details_screen.dart';
import 'add_edit_subject_screen.dart';

class SubjectListScreen extends StatelessWidget {
  const SubjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = AttendXScope.of(context);
    final palette = model.themePalette;
    final gap = model.overallAttendance - model.minimumAttendance;

    return PageFrame(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Subjects',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            BouncyTap(
              onTap: () => Navigator.pushNamed(context, AddEditSubjectScreen.route),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: palette.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: palette.accent.withValues(alpha: 0.3)),
                ),
                child: Icon(CupertinoIcons.plus, color: palette.accent, size: 18),
              ),
            ),
          ],
        ),
        GlassCard(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              ProgressRing(
                value: model.overallAttendance / 100,
                label: '${model.overallAttendance.toStringAsFixed(1)}%',
                color: model.overallAttendance >= model.minimumAttendance
                    ? (model.isDarkTheme ? palette.accent : AppPalette.green)
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
                            color: palette.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      model.totalClasses == 0
                           ? 'Start marking classes to see your live attendance status.'
                           : gap >= 0
                               ? 'Above min by ${gap.toStringAsFixed(1)}%.'
                               : 'Below min by ${gap.abs().toStringAsFixed(1)}%.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: palette.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (model.subjects.isEmpty)
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(CupertinoIcons.book, color: palette.textMuted, size: 42),
                const SizedBox(height: 12),
                Text('No subjects added',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: palette.textPrimary)),
                const SizedBox(height: 6),
                Text('Create your first subject to begin.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: palette.textSecondary)),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AddEditSubjectScreen.route),
                  icon: const Icon(CupertinoIcons.plus, size: 16),
                  label: const Text('Add Subject'),
                ),
              ],
            ),
          )
        else ...[
          if (model.subjects.any((s) => !s.isLab)) ...[
            const SectionHeader(title: 'Theory Subjects'),
            const SizedBox(height: 12),
            ...model.subjects.where((s) => !s.isLab).map(
              (subject) => SubjectManageCard(subject: subject),
            ),
            const SizedBox(height: 24),
          ],
          if (model.subjects.any((s) => s.isLab)) ...[
            const SectionHeader(title: 'Lab Subjects'),
            const SizedBox(height: 12),
            ...model.subjects.where((s) => s.isLab).map(
              (subject) => SubjectManageCard(subject: subject),
            ),
          ],
        ],
        const SizedBox(height: 80),
      ],
    );
  }
}

class SubjectManageCard extends StatelessWidget {
  const SubjectManageCard({super.key, required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context) {
    final model = AttendXScope.of(context);
    final palette = model.themePalette;

    return Dismissible(
      key: ValueKey('manage_sem_${model.currentSemester}_subj_${subject.name}_${subject.code}_${subject.isLab}'),
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
        AppHaptics.heavy();
        model.deleteSubject(subject);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppPalette.red.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Icon(CupertinoIcons.delete, color: AppPalette.red),
      ),
      child: GlassCard(
        onTap: () => Navigator.push(
          context,
          PremiumRoute(child: SubjectDetailsScreen(subject: subject)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SubjectIcon(subject: subject, size: 50),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${subject.present}/${subject.total} • ${subject.percentage.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            StatusPill(label: subject.statusLabel, color: subject.statusColor),
          ],
        ),
      ),
    );
  }
}
