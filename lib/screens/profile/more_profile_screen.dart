import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../themes/palette.dart';
import '../../models/attendx_model.dart';
import '../../widgets/common.dart';
import '../../shell/attendx_shell.dart';
import 'settings_screen.dart';
import 'backup_restore_screen.dart';
import 'statistics_screen.dart';

class MoreProfileScreen extends StatelessWidget {
  const MoreProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = AttendXScope.of(context);
    return PageFrame(
      children: [
        // Profile card
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppPalette.green, AppPalette.blue],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(CupertinoIcons.person_fill,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.studentName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppPalette.ink,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${model.overallAttendance.toStringAsFixed(1)}% overall',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppPalette.slate,
                          ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, ProfileScreen.route),
                child: const Icon(CupertinoIcons.chevron_right, color: AppPalette.slate, size: 18),
              ),
            ],
          ),
        ),
        // Semester selector
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Semester',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppPalette.slate,
                    ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(
                      'Sem ${model.currentSemester}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppPalette.ink,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(width: 12),
                    ...List.generate(8, (index) {
                      final sem = index + 1;
                      final isCurrent = sem == model.currentSemester;
                      return GestureDetector(
                        onTap: () {
                          if (!isCurrent) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                title: Text('Switch to Semester $sem?'),
                                content: Text(
                                  'Switch active semester to Semester $sem. Your current semester\'s subjects, timetable, and attendance records will remain safely saved.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () {
                                      model.setSemester(sem);
                                      Navigator.pop(ctx);
                                    },
                                    child: const Text('Switch'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          margin: const EdgeInsets.only(left: 4),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? AppPalette.green.withValues(alpha: 0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCurrent
                                  ? AppPalette.green
                                  : AppPalette.glassLine,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$sem',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: isCurrent
                                        ? AppPalette.green
                                        : AppPalette.slate,
                                    fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                                  ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Quick actions
        SettingsTile(
          icon: Icons.bar_chart_rounded,
          title: 'Statistics',
          subtitle: 'Weekly, monthly, and subject analytics',
          onTap: () => Navigator.pushNamed(context, StatisticsScreen.route),
        ),
        SettingsTile(
          icon: Icons.calculate_rounded,
          title: 'Bunk Calculator',
          subtitle: 'Smart bunk predictions and test attendance',
          onTap: () {
            final shell = AttendXShellScope.maybeOf(context);
            if (shell != null) {
              shell.switchToTab(3);
            } else {
              Navigator.pushNamed(context, '/bunk-calculator');
            }
          },
        ),
        SettingsTile(
          icon: Icons.cloud_upload_rounded,
          title: 'Backup & Restore',
          subtitle: 'JSON export/import and local backup',
          onTap: () => Navigator.pushNamed(context, BackupRestoreScreen.route),
        ),
        SettingsTile(
          icon: CupertinoIcons.share_up,
          title: 'Export Data',
          subtitle: 'Export & share semester CSV reports',
          onTap: () => Navigator.pushNamed(context, '/excel-export'),
        ),
        SettingsTile(
          icon: CupertinoIcons.settings,
          title: 'Settings',
          subtitle: 'Attendance minimum and warnings',
          onTap: () => Navigator.pushNamed(context, SettingsScreen.route),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  static const route = '/profile';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = AttendXScope.of(context);
    return DetailShell(
      title: 'Profile',
      children: [
        GlassCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppPalette.green, AppPalette.blue],
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(CupertinoIcons.person_fill,
                    color: Colors.white, size: 42),
              ),
              const SizedBox(height: 14),
              Text(
                model.studentName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Semester ${model.currentSemester}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.58),
                    ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: StatGlassTile(
                title: 'Overall',
                value: '${model.overallAttendance.toStringAsFixed(1)}%',
                icon: CupertinoIcons.percent,
                color: AppPalette.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatGlassTile(
                title: 'Streak',
                value: '${model.currentStreak}',
                icon: Icons.local_fire_department_rounded,
                color: AppPalette.yellow,
              ),
            ),
          ],
        ),
        SettingsTile(
          icon: CupertinoIcons.settings,
          title: 'Settings',
          subtitle: 'Minimum criteria, warnings, and appearance',
          onTap: () => Navigator.pushNamed(context, SettingsScreen.route),
        ),
        SettingsTile(
          icon: Icons.backup_rounded,
          title: 'Backup & Restore',
          subtitle: 'Export or import JSON backup',
          onTap: () => Navigator.pushNamed(context, BackupRestoreScreen.route),
        ),
        SettingsTile(
          icon: Icons.auto_awesome_rounded,
          title: 'Onboarding Preview',
          subtitle: 'View the first-run experience screens',
          onTap: () => Navigator.pushNamed(context, '/onboarding'),
        ),
      ],
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppPalette.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppPalette.green, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppPalette.ink,
                    )),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppPalette.slate,
                      ),
                ),
              ],
            ),
          ),
          trailing ?? const Icon(CupertinoIcons.chevron_right, size: 16, color: AppPalette.slate),
        ],
      ),
    );
  }
}
