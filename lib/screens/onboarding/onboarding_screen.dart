import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../themes/palette.dart';
import '../../widgets/common.dart';

class OnboardingScreen extends StatelessWidget {
  static const route = '/onboarding';

  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      OnboardingPageData(
        'One-tap attendance',
        "Mark Present or Absent from today's schedule without opening extra screens.",
        CupertinoIcons.check_mark_circled,
        AppPalette.green,
      ),
      OnboardingPageData(
        'Dedicated Semesters',
        'Each semester keeps its own timetable, CT windows, stats, and backup archive.',
        CupertinoIcons.layers_alt,
        AppPalette.blue,
      ),
      OnboardingPageData(
        'Plan every bunk',
        'Know how many classes you can miss and what to attend to recover safely.',
        Icons.calculate_rounded,
        AppPalette.purple,
      ),
    ];

    return GradientScaffold(
      child: SafeArea(
        child: PageFrame(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 34),
          children: [
            const TopBar(showBack: true, title: 'Welcome'),
            SizedBox(
              height: 470,
              child: PageView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: pages.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: OnboardingPanel(data: pages[index], index: index),
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Start Marking Attendance'),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPanel extends StatelessWidget {
  const OnboardingPanel({super.key, required this.data, required this.index});

  final OnboardingPageData data;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(26),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(46),
            ),
            child: Icon(data.icon, color: data.color, size: 72),
          ),
          const SizedBox(height: 32),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 14),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.45,
                  color:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.62),
                ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (dot) => AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: dot == index ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: dot == index
                      ? data.color
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPageData {
  const OnboardingPageData(this.title, this.subtitle, this.icon, this.color);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}
