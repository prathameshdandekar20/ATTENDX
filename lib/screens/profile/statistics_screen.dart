import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../themes/palette.dart';
import '../../models/attendx_model.dart';
import '../../widgets/common.dart';

class StatisticsScreen extends StatelessWidget {
  static const route = '/statistics';

  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = AttendXScope.of(context);
    final best = [...model.subjects]
      ..sort((a, b) => b.percentage.compareTo(a.percentage));
    final lowest = [...model.subjects]
      ..sort((a, b) => a.percentage.compareTo(b.percentage));
    return DetailShell(
      title: 'Statistics',
      children: [
        const HeroTitle(
          eyebrow: 'Analytics for smarter attendance',
          title: 'Statistics',
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Weekly Attendance'),
              const SizedBox(height: 18),
              const MiniBarChart(),
            ],
          ),
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Monthly Trend'),
              const SizedBox(height: 18),
              const TrendLineChart(),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: StatGlassTile(
                title: 'Best',
                value: best.isEmpty ? '-' : best.first.name,
                icon: CupertinoIcons.arrow_up_right,
                color: model.isDarkTheme ? model.themePalette.accent : AppPalette.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatGlassTile(
                title: 'Lowest',
                value: lowest.isEmpty ? '-' : lowest.first.name,
                icon: CupertinoIcons.arrow_down_right,
                color: AppPalette.red,
              ),
            ),
          ],
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Subject Comparison'),
              const SizedBox(height: 14),
              if (model.subjects.isEmpty)
                Text(
                  'Add subjects and mark classes to unlock comparisons.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: model.themePalette.textSecondary),
                )
              else
                ...model.subjects.map(
                (subject) => TrendRow(
                  label: subject.name,
                  value: '${subject.percentage.round()}%',
                  percent: subject.percentage / 100,
                  color: subject.statusColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MiniBarChart extends StatelessWidget {
  const MiniBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final model = AttendXScope.of(context);
    final values = [0.82, 0.74, 0.9, 0.78, 0.86, 0.8, 0.92];
    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return SizedBox(
      height: 164,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (index) {
          final color = values[index] >= 0.75
              ? (model.isDarkTheme ? model.themePalette.accent : AppPalette.green)
              : AppPalette.red;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: values[index]),
                        duration: Duration(milliseconds: 600 + index * 80),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) => FractionallySizedBox(
                          heightFactor: value,
                          child: Container(
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.78),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(labels[index], style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class TrendLineChart extends StatelessWidget {
  const TrendLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    final model = AttendXScope.of(context);
    final chartColor = model.isDarkTheme ? model.themePalette.accent : AppPalette.purple;
    return SizedBox(
      height: 150,
      child: CustomPaint(
        painter: TrendLinePainter(
          color: chartColor,
          values: const [0.64, 0.7, 0.68, 0.76, 0.74, 0.82, 0.86],
        ),
        child: Container(),
      ),
    );
  }
}

class TrendLinePainter extends CustomPainter {
  TrendLinePainter({required this.color, required this.values});

  final Color color;
  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * (i / (values.length - 1));
      final y = size.height - (values[i] * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.0)],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant TrendLinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}
