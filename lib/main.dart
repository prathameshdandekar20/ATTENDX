import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

import 'models/attendx_model.dart';
import 'screens/onboarding/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/student_setup_screen.dart';
import 'screens/timetable/timetable_screen.dart';
import 'screens/ct_tracking/ct_tracking_screen.dart';
import 'screens/subjects/add_edit_subject_screen.dart';
import 'screens/profile/statistics_screen.dart';
import 'screens/profile/more_profile_screen.dart';
import 'screens/profile/settings_screen.dart';
import 'screens/profile/backup_restore_screen.dart';
import 'screens/profile/excel_export_screen.dart';
import 'screens/profile/bunk_calculator_screen.dart';
import 'shell/attendx_shell.dart';
import 'themes/palette.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AttendXApp(model: await AttendXModel.load()));
}

class AttendXApp extends StatefulWidget {
  const AttendXApp({super.key, required this.model});

  final AttendXModel model;

  @override
  State<AttendXApp> createState() => _AttendXAppState();
}

class _AttendXAppState extends State<AttendXApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _unlockHighRefreshRate();
    });
  }

  Future<void> _unlockHighRefreshRate() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final modes = await FlutterDisplayMode.supported;
        if (modes.isNotEmpty) {
          final highest = modes.reduce(
            (curr, next) => curr.refreshRate > next.refreshRate ? curr : next,
          );
          await FlutterDisplayMode.setPreferredMode(highest);
        }
      } catch (_) {
        try {
          await FlutterDisplayMode.setHighRefreshRate();
        } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AttendXScope(
      model: widget.model,
      child: AnimatedBuilder(
        animation: widget.model,
        builder: (context, _) {
          final palette = widget.model.themePalette;
          final scheme = palette.isDark
              ? ColorScheme.dark(
                  primary: palette.accent,
                  secondary: palette.accentSecondary,
                  surface: palette.navBackground,
                  onSurface: palette.textPrimary,
                  outline: palette.cardBorder,
                )
              : ColorScheme.fromSeed(
                  seedColor: const Color(0xFF88B83E),
                  brightness: Brightness.light,
                );

          return MaterialApp(
            title: 'AttendX',
            debugShowCheckedModeBanner: false,
            themeMode: palette.isDark ? ThemeMode.dark : ThemeMode.light,
            theme: _theme(scheme, palette),
            darkTheme: _theme(scheme, palette),
            home: const _RootDecider(),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case SplashScreen.route:
                  return PremiumRoute(child: const SplashScreen());
                case OnboardingScreen.route:
                  return PremiumRoute(child: const OnboardingScreen());
                case TimetableScreen.route:
                  return PremiumRoute(child: const TimetableScreen());
                case StatisticsScreen.route:
                  return PremiumRoute(child: const StatisticsScreen());
                case CtTrackingScreen.route:
                  return PremiumRoute(child: const CtTrackingScreen());
                case BunkCalculatorScreen.route:
                  return PremiumRoute(child: const BunkCalculatorScreen());
                case BackupRestoreScreen.route:
                  return PremiumRoute(child: const BackupRestoreScreen());
                case ExcelExportScreen.route:
                  return PremiumRoute(child: const ExcelExportScreen());
                case SettingsScreen.route:
                  return PremiumRoute(child: const SettingsScreen());
                case ProfileScreen.route:
                  return PremiumRoute(child: const ProfileScreen());
                case AddEditSubjectScreen.route:
                  return PremiumRoute(child: const AddEditSubjectScreen());
                default:
                  return null;
              }
            },
          );
        },
      ),
    );
  }

  ThemeData _theme(ColorScheme scheme, AppThemePalette palette) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.isDark ? palette.accent : AppPalette.green,
          foregroundColor: palette.isDark ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.isDark ? palette.accent : AppPalette.greenDark,
          side: BorderSide(color: palette.isDark ? palette.cardBorder : AppPalette.glassLine),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0, color: palette.textPrimary),
        displayMedium: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0, color: palette.textPrimary),
        headlineLarge: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0, color: palette.textPrimary),
        headlineMedium: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0, color: palette.textPrimary),
        titleLarge: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0, color: palette.textPrimary),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0, color: palette.textPrimary),
        titleSmall: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0, color: palette.textPrimary),
        bodyLarge: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 0, color: palette.textPrimary),
        bodyMedium: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 0, color: palette.textSecondary),
        bodySmall: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 0, color: palette.textMuted),
        labelLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0, color: palette.textPrimary),
        labelSmall: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0, color: palette.textMuted),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.isDark ? const Color(0xFF16130E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: palette.cardBorder),
        ),
        titleTextStyle: TextStyle(
          color: palette.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: TextStyle(
          color: palette.textSecondary,
          fontSize: 14,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}

class _RootDecider extends StatelessWidget {
  const _RootDecider();

  @override
  Widget build(BuildContext context) {
    final model = AttendXScope.of(context);
    return model.isSetup ? const AttendXShell() : const StudentSetupScreen();
  }
}

class PremiumRoute<T> extends PageRouteBuilder<T> {
  PremiumRoute({required Widget child})
      : super(
          transitionDuration: const Duration(milliseconds: 420),
          reverseTransitionDuration: const Duration(milliseconds: 320),
          pageBuilder: (_, __, ___) => child,
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.035),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}
