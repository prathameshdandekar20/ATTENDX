import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../themes/palette.dart';
import '../models/attendx_model.dart';
import '../widgets/common.dart';
import '../screens/today/mark_attendance_screen.dart';
import '../screens/timetable/timetable_screen.dart';
import '../screens/profile/bunk_calculator_screen.dart';
import '../screens/ct_tracking/ct_tracking_screen.dart';
import '../screens/profile/more_profile_screen.dart';

import 'package:flutter/services.dart';

class AttendXShellScope extends InheritedWidget {
  const AttendXShellScope({
    super.key,
    required this.currentIndex,
    required this.switchToTab,
    required super.child,
  });

  final int currentIndex;
  final ValueChanged<int> switchToTab;

  static AttendXShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AttendXShellScope>();

  @override
  bool updateShouldNotify(AttendXShellScope oldWidget) =>
      currentIndex != oldWidget.currentIndex;
}

class AttendXShell extends StatefulWidget {
  const AttendXShell({super.key});

  @override
  State<AttendXShell> createState() => _AttendXShellState();
}

class _AttendXShellState extends State<AttendXShell> {
  int _index = 0;
  DateTime? _lastBackPressTime;

  final _pages = const [
    MarkAttendanceScreen(),
    TimetableScreen(),
    CtTrackingScreen(),
    BunkCalculatorScreen(),
    MoreProfileScreen(),
  ];

  void _switchTab(int index) {
    setState(() => _index = index);
  }

  void _handleBackPress() {
    // If not on Today page (index 0), navigate to Today first
    if (_index != 0) {
      setState(() => _index = 0);
      return;
    }

    // On Today page: double back press to exit
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      final model = AttendXScope.of(context);
      final palette = model.themePalette;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 76),
          backgroundColor: palette.isDark ? const Color(0xFF1E1A14) : AppPalette.ink.withValues(alpha: 0.92),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: palette.isDark ? palette.cardBorder : Colors.transparent),
          ),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.info_circle_fill, color: palette.accent, size: 20),
              const SizedBox(width: 12),
              Text(
                'Press back again to exit',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    // Exit application on second back press within 2s
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: AttendXShellScope(
        currentIndex: _index,
        switchToTab: _switchTab,
        child: GradientScaffold(
          child: SafeArea(
            child: Stack(
              children: [
                IndexedStack(
                  index: _index,
                  children: _pages,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AttendXBottomNav(
                    currentIndex: _index,
                    onChanged: _switchTab,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AttendXBottomNav extends StatelessWidget {
  const AttendXBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final model = AttendXScope.of(context);
    final palette = model.themePalette;

    final items = [
      _NavItem(CupertinoIcons.doc_text, 'Today'),
      _NavItem(CupertinoIcons.calendar, 'Schedule'),
      _NavItem(CupertinoIcons.chart_pie, 'Breakdown'),
      _NavItem(CupertinoIcons.moon_zzz_fill, 'Bunk'),
      _NavItem(CupertinoIcons.settings, 'Settings'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      decoration: BoxDecoration(
        color: palette.navBackground,
        border: Border(
          top: BorderSide(color: palette.navBorder, width: palette.isDark ? 1.0 : 0.5),
        ),
        boxShadow: [
          if (palette.isDark)
            BoxShadow(
              color: palette.accentGlow.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: List.generate(items.length, (index) {
              final selected = index == currentIndex;
              final item = items[index];
              final activeColor = palette.accent;
              final inactiveColor = palette.navUnselected;

              return Expanded(
                child: BouncyTap(
                  scaleDown: 0.92,
                  onTap: () => onChanged(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 22,
                          color: selected ? activeColor : inactiveColor,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                            color: selected ? activeColor : inactiveColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

