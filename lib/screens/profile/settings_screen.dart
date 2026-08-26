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
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'App Theme'),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _ThemeChoiceCard(
                      title: 'Obsidian Gold',
                      subtitle: 'OLED Pitch Black',
                      icon: Icons.star_rounded,
                      accentColor: AppPalette.gold,
                      bgColor: const Color(0xFF14110C),
                      isSelected: model.selectedTheme == 'obsidian_gold',
                      onTap: () {
                        AppHaptics.medium();
                        model.setTheme('obsidian_gold');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ThemeChoiceCard(
                      title: 'Emerald Mint',
                      subtitle: 'Fresh Light',
                      icon: Icons.eco_rounded,
                      accentColor: AppPalette.green,
                      bgColor: const Color(0xFFE5F7EF),
                      isSelected: model.selectedTheme == 'emerald_mint',
                      onTap: () {
                        AppHaptics.medium();
                        model.setTheme('emerald_mint');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SettingsTile(
          icon: Icons.inventory_2_rounded,
          title: 'Auto archive semesters',
          subtitle: 'Keep old semester data separate',
          trailing: Switch(
            value: true,
            activeThumbColor: model.themePalette.accent,
            activeTrackColor: model.themePalette.accent.withValues(alpha: 0.38),
            onChanged: (_) {},
          ),
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
              Divider(color: model.themePalette.divider, height: 20),
              _ResetTile(
                icon: CupertinoIcons.clear_circled,
                title: 'Reset Attendance Only',
                subtitle: 'Clear attendance marks, logs, and CT snapshots. Keeps subjects & schedule.',
                color: AppPalette.orange,
                onTap: () => _confirmReset(
                  context,
                  title: 'Reset Attendance Only?',
                  message: 'This will reset all attendance counters, logs, and CT snapshots to zero. Your subjects and weekly schedule will be kept.',
                  onConfirm: () {
                    model.resetAttendance();
                    Navigator.pop(context);
                  },
                ),
              ),
              Divider(color: model.themePalette.divider, height: 20),
              _ResetTile(
                icon: CupertinoIcons.calendar_badge_minus,
                title: 'Reset Timetable Only',
                subtitle: 'Clear weekly schedule and extra lectures. Keeps attendance & subjects.',
                color: AppPalette.purple,
                onTap: () => _confirmReset(
                  context,
                  title: 'Reset Timetable Only?',
                  message: 'This will clear all entries from your weekly timetable and extra lectures. Your subjects and attendance records will remain safe.',
                  onConfirm: () {
                    model.resetSchedule();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _ThemeChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color bgColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeChoiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.bgColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkCard = bgColor != const Color(0xFFE5F7EF);

    return BouncyTap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? accentColor : (isDarkCard ? const Color(0x33E5B842) : Colors.white),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: accentColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: accentColor, size: 22),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: accentColor, size: 18),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: isDarkCard ? Colors.white : AppPalette.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDarkCard ? const Color(0xFFA89F8B) : AppPalette.slate,
              ),
            ),
          ],
        ),
      ),
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
    final model = AttendXScope.of(context);
    final palette = model.themePalette;

    return BouncyTap(
      onTap: onTap,
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
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_right, color: palette.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}
