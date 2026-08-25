import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../themes/palette.dart';
import '../../models/attendx_model.dart';
import '../../widgets/common.dart';
import 'more_profile_screen.dart'; // For SettingsTile

class SettingsScreen extends StatelessWidget {
  static const route = '/settings';

  const SettingsScreen({super.key});

  void _confirmReset(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppPalette.slate)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppPalette.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              onConfirm();
              Navigator.pop(ctx);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = AttendXScope.of(context);
    return DetailShell(
      title: 'Settings',
      children: [
        const HeroTitle(
          eyebrow: 'Personalize your attendance rules',
          title: 'Settings',
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Minimum Attendance'),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: model.minimumAttendance.clamp(0, 100),
                      min: 0,
                      max: 100,
                      divisions: 100,
                      onChanged: model.setMinimumAttendance,
                    ),
                  ),
                  Text(
                    '${model.minimumAttendance.round()}%',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppPalette.green,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SettingsTile(
          icon: CupertinoIcons.moon,
          title: 'Dark mode compatible',
          subtitle: 'Follow system appearance',
          trailing: Switch(value: true, onChanged: (_) {}),
        ),
        SettingsTile(
          icon: Icons.inventory_2_rounded,
          title: 'Auto archive semesters',
          subtitle: 'Keep old semester data separate',
          trailing: Switch(value: true, onChanged: (_) {}),
        ),
        const SizedBox(height: 20),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Danger Zone'),
              const SizedBox(height: 14),
              _ResetTile(
                icon: CupertinoIcons.delete,
                title: 'Complete Reset',
                subtitle: 'Wipe all profile, subjects, schedules, and attendance logs.',
                color: AppPalette.red,
                onTap: () => _confirmReset(
                  context,
                  title: 'Complete Reset?',
                  message: 'This will permanently delete all your data including student name, subjects, weekly timetable, and all attendance logs. This action cannot be undone.',
                  onConfirm: () {
                    model.completeReset();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ),
              const Divider(color: AppPalette.glassLine, height: 20),
              _ResetTile(
                icon: CupertinoIcons.clear_circled,
                title: 'Reset Attendance Only',
                subtitle: 'Clear attendance marks, logs, and CT snapshots. Keeps subjects & schedule.',
                color: AppPalette.orange,
                onTap: () => _confirmReset(
                  context,
                  title: 'Reset Attendance?',
                  message: 'This will reset all subject attendance counters to 0, clear your daily logs, and reset CT milestones. Your subjects list and timetable schedule will be kept.',
                  onConfirm: () => model.resetAttendance(),
                ),
              ),
              const Divider(color: AppPalette.glassLine, height: 20),
              _ResetTile(
                icon: CupertinoIcons.calendar_today,
                title: 'Reset Schedule Only',
                subtitle: 'Wipe all entries in your weekly timetable. Keeps subjects and attendance logs.',
                color: AppPalette.blue,
                onTap: () => _confirmReset(
                  context,
                  title: 'Reset Timetable Schedule?',
                  message: 'This will clear all classes/slots from your weekly timetable. Your subject lists and attendance logs will not be affected.',
                  onConfirm: () => model.resetSchedule(),
                ),
              ),
              const Divider(color: AppPalette.glassLine, height: 20),
              _ResetTile(
                icon: CupertinoIcons.clock,
                title: 'Reset CT Tracking Only',
                subtitle: 'Clear CT1 snapshot and completion date.',
                color: AppPalette.purple,
                onTap: () => _confirmReset(
                  context,
                  title: 'Reset CT Tracking?',
                  message: 'This will reset the completed date and snapshot for CT1 tracking. It does not affect normal attendance logs.',
                  onConfirm: () => model.resetCTTracking(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResetTile extends StatelessWidget {
  const _ResetTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppPalette.ink,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppPalette.slate,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_right, color: AppPalette.slate, size: 16),
          ],
        ),
      ),
    );
  }
}
