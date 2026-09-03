import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../themes/palette.dart';
import '../models/attendx_model.dart';
import '../models/subject.dart';
import '../models/attendance_log.dart';

class AppHaptics {
  static void light() => HapticFeedback.mediumImpact();
  static void medium() => HapticFeedback.heavyImpact();
  static void selection() => HapticFeedback.mediumImpact();
  static void heavy() => HapticFeedback.heavyImpact();
  static void strong() => HapticFeedback.heavyImpact();
}

class BouncyTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final Duration duration;

  const BouncyTap({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.95,
    this.duration = const Duration(milliseconds: 110),
  });

  @override
  State<BouncyTap> createState() => _BouncyTapState();
}

class _BouncyTapState extends State<BouncyTap> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        AppHaptics.selection();
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? widget.scaleDown : 1.0,
        duration: widget.duration,
        curve: Curves.easeInOutCubic,
        child: widget.child,
      ),
    );
  }
}

class AnimatedPercentageText extends StatelessWidget {
  final double percentage;
  final TextStyle? style;
  final int fractionDigits;

  const AnimatedPercentageText({
    super.key,
    required this.percentage,
    this.style,
    this.fractionDigits = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: percentage),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          '${value.toStringAsFixed(fractionDigits)}%',
          style: style,
        );
      },
    );
  }
}

class AnimatedCountText extends StatelessWidget {
  final int count;
  final TextStyle? style;

  const AnimatedCountText({
    super.key,
    required this.count,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: count.toDouble()),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          '${value.round()}',
          style: style,
        );
      },
    );
  }
}

class GradientScaffold extends StatelessWidget {
  const GradientScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    AppThemePalette palette = AppThemePalette.obsidianGold;
    try {
      final scope = context.dependOnInheritedWidgetOfExactType<AttendXScope>();
      if (scope?.notifier != null) {
        palette = scope!.notifier!.themePalette;
      }
    } catch (_) {}

    return Scaffold(
      backgroundColor: palette.isDark ? AppPalette.obsidianBlack : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: palette.scaffoldGradient,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SizedBox.expand(child: child),
          ),
        ),
      ),
    );
  }
}

class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(22, 18, 22, 116),
  });

  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final separatedChildren = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) separatedChildren.add(const SizedBox(height: 18));
      separatedChildren.add(children[i]);
    }

    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: padding,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => separatedChildren[index],
              childCount: separatedChildren.length,
            ),
          ),
        ),
      ],
    );
  }
}

class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 28,
    this.onTap,
    this.borderOpacity = 0.64,
    this.blur = 22,
    this.glowColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final VoidCallback? onTap;
  final double borderOpacity;
  final double blur;
  final Color? glowColor;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    AppThemePalette palette = AppThemePalette.obsidianGold;
    try {
      final scope = context.dependOnInheritedWidgetOfExactType<AttendXScope>();
      if (scope?.notifier != null) {
        palette = scope!.notifier!.themePalette;
      }
    } catch (_) {}

    final borderColor = palette.isDark
        ? palette.cardBorder
        : Colors.white.withValues(alpha: widget.borderOpacity);
    final fill = palette.cardFill;

    final content = Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: borderColor, width: 1.0),
        color: fill,
        boxShadow: [
          BoxShadow(
            color: widget.glowColor ?? palette.cardShadow,
            blurRadius: palette.isDark ? 16 : 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: widget.child,
    );

    if (widget.onTap == null) {
      return RepaintBoundary(child: content);
    }

    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          AppHaptics.light();
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _pressed = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOutCubic,
          child: content,
        ),
      ),
    );
  }
}

class FrostedIcon extends StatelessWidget {
  const FrostedIcon({
    super.key,
    required this.icon,
    this.color = AppPalette.green,
    this.size = 52,
    this.onTap,
    this.badge = false,
  });

  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback? onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GlassCard(
          onTap: onTap,
          radius: size / 2,
          padding: EdgeInsets.zero,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, color: color, size: size * 0.42),
          ),
        ),
        if (badge)
          Positioned(
            right: 5,
            top: 5,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: AppPalette.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

class GreetingPill extends StatelessWidget {
  const GreetingPill({super.key});

  @override
  Widget build(BuildContext context) {
    final model = AttendXScope.of(context);
    final hour = model.today.hour;
    final IconData greetIcon;
    final Color greetColor;
    if (hour < 6) {
      greetIcon = CupertinoIcons.moon_stars;
      greetColor = AppPalette.purple;
    } else if (hour < 12) {
      greetIcon = CupertinoIcons.sun_max;
      greetColor = AppPalette.yellow;
    } else if (hour < 17) {
      greetIcon = CupertinoIcons.cloud_sun;
      greetColor = AppPalette.orange;
    } else if (hour < 21) {
      greetIcon = CupertinoIcons.sunset;
      greetColor = AppPalette.orange;
    } else {
      greetIcon = CupertinoIcons.moon_stars;
      greetColor = AppPalette.purple;
    }
    return GlassCard(
      radius: 26,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(greetIcon, color: greetColor, size: 18),
          const SizedBox(width: 10),
          Text(
            '${greetingFor(model.today)}, ${model.firstName}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({super.key, this.showBack = false, this.title});

  final bool showBack;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FrostedIcon(
          icon: showBack ? CupertinoIcons.chevron_left : CupertinoIcons.person,
          color: Theme.of(context).colorScheme.onSurface,
          onTap: showBack
              ? () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                }
              : () {
                  Navigator.pushNamed(context, '/profile');
                },
        ),
        Expanded(
          child: Center(
            child: title == null
                ? const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: GreetingPill(),
                  )
                : Text(
                    title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
          ),
        ),
        const SizedBox(width: 52),
      ],
    );
  }
}

class DetailShell extends StatelessWidget {
  const DetailShell({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: SafeArea(
        child: PageFrame(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 34),
          children: [
            TopBar(showBack: true, title: title),
            ...children,
          ],
        ),
      ),
    );
  }
}

class SubjectIcon extends StatelessWidget {
  const SubjectIcon({super.key, required this.subject, this.size = 58});

  final Subject subject;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: subject.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.4),
      ),
      child: Icon(subject.icon, color: subject.color, size: size * 0.46),
    );
  }
}

class HeroTitle extends StatelessWidget {
  const HeroTitle({
    super.key,
    required this.eyebrow,
    required this.title,
    this.accent,
  });

  final String eyebrow;
  final String title;
  final String? accent;

  @override
  Widget build(BuildContext context) {
    final words = title.split(' ');
    final hasAccent = accent != null && title.contains(accent!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 34,
                  height: 1.05,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
            children: hasAccent
                ? words.map((word) {
                    final clean = word.replaceAll(RegExp(r'[^A-Za-z]'), '');
                    return TextSpan(
                      text: '$word ',
                      style: TextStyle(
                        color: clean == accent ? AppPalette.green : null,
                      ),
                    );
                  }).toList()
                : [TextSpan(text: title)],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          eyebrow,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.62),
              ),
        ),
      ],
    );
  }
}

class MetricData {
  const MetricData(this.icon, this.label, this.value, this.color);
  final IconData icon;
  final String label;
  final String value;
  final Color color;
}

class MetricTile extends StatelessWidget {
  const MetricTile({super.key, required this.metric});

  final MetricData metric;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: metric.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(metric.icon, color: metric.color, size: 18),
        ),
        const SizedBox(height: 8),
        Text(
          metric.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.56),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          metric.value,
          maxLines: 1,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: metric.value.contains('%')
                    ? AppPalette.green
                    : null,
              ),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppPalette.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, color: AppPalette.green, size: 28),
          ),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppPalette.slate),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onTap, child: Text(action)),
        ],
      ),
    );
  }
}

class RunningTrailBorder extends StatefulWidget {
  const RunningTrailBorder({
    super.key,
    required this.child,
    required this.trailColor,
    this.borderRadius = 24.0,
    this.strokeWidth = 2.0,
    this.duration = const Duration(milliseconds: 3000),
  });

  final Widget child;
  final Color trailColor;
  final double borderRadius;
  final double strokeWidth;
  final Duration duration;

  @override
  State<RunningTrailBorder> createState() => _RunningTrailBorderState();
}

class _RunningTrailBorderState extends State<RunningTrailBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            foregroundPainter: _TrailBorderPainter(
              animationValue: _controller.value,
              borderRadius: widget.borderRadius,
              trailColor: widget.trailColor,
              strokeWidth: widget.strokeWidth,
            ),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _TrailBorderPainter extends CustomPainter {
  final double animationValue;
  final double borderRadius;
  final Color trailColor;
  final double strokeWidth;

  _TrailBorderPainter({
    required this.animationValue,
    required this.borderRadius,
    required this.trailColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final angle = animationValue * 2 * 3.141592653589793;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        colors: [
          trailColor.withValues(alpha: 0.0),
          trailColor.withValues(alpha: 0.0),
          trailColor.withValues(alpha: 0.7),
          trailColor,
          trailColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.7, 0.9, 0.98, 1.0],
        transform: GradientRotation(angle),
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _TrailBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.trailColor != trailColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class SetupTextField extends StatelessWidget {
  const SetupTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      decoration: setupDecoration(context, label, icon).copyWith(hintText: hint),
    );
  }
}

InputDecoration setupDecoration(
  BuildContext context,
  String label,
  IconData icon,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final accent = isDark ? AppPalette.gold : AppPalette.green;
  final border = isDark ? const Color(0x38E5B842) : Colors.white.withValues(alpha: 0.7);
  final fill = isDark ? const Color(0xFF18140E) : Colors.white.withValues(alpha: 0.72);

  return InputDecoration(
    prefixIcon: Icon(icon, color: accent),
    labelText: label,
    labelStyle: TextStyle(color: isDark ? const Color(0xFFB8AE98) : AppPalette.slate),
    filled: true,
    fillColor: fill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide(color: border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide(color: border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide(color: accent, width: 1.4),
    ),
  );
}

class AnimatedPressable extends StatefulWidget {
  const AnimatedPressable({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<AnimatedPressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class StatGlassTile extends StatelessWidget {
  const StatGlassTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 24,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.55),
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: color == AppPalette.green ? AppPalette.green : null,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class TrendRow extends StatelessWidget {
  const TrendRow({
    super.key,
    required this.label,
    required this.value,
    required this.percent,
    required this.color,
  });

  final String label;
  final String value;
  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: color,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: percent.clamp(0.0, 1.0).toDouble(),
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryTile extends StatelessWidget {
  const HistoryTile({super.key, required this.log});

  final AttendanceLog log;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: log.present
                  ? AppPalette.green.withValues(alpha: 0.12)
                  : AppPalette.red.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              log.present
                  ? CupertinoIcons.check_mark_circled
                  : CupertinoIcons.xmark_circle,
              color: log.present ? AppPalette.green : AppPalette.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.date, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 3),
                Text(
                  log.note,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.55),
                      ),
                ),
              ],
            ),
          ),
          StatusPill(
            label: log.present ? 'Present' : 'Absent',
            color: log.present ? AppPalette.green : AppPalette.red,
          ),
        ],
      ),
    );
  }
}

class BackupItem {
  const BackupItem(this.name, this.date, this.size);
  final String name;
  final String date;
  final String size;
}

class GlassTextField extends StatelessWidget {
  const GlassTextField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppPalette.gold : AppPalette.green;
    final border = isDark ? const Color(0x38E5B842) : Colors.white.withValues(alpha: 0.5);
    final fill = isDark ? const Color(0xFF18140E) : Colors.white.withValues(alpha: 0.58);

    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: accent),
        labelText: label,
        labelStyle: TextStyle(color: isDark ? const Color(0xFFB8AE98) : AppPalette.slate),
        filled: true,
        fillColor: fill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: accent, width: 1.4),
        ),
      ),
    );
  }
}

class PredictionCard extends StatelessWidget {
  const PredictionCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.56),
                ),
          ),
        ],
      ),
    );
  }
}

class WarningTile extends StatelessWidget {
  const WarningTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.56),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BackupHeroCard extends StatelessWidget {
  const BackupHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.button,
    this.onPressed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String button;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.56),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: onPressed ?? () {},
            child: Text(button),
          ),
        ],
      ),
    );
  }
}

class BackupRow extends StatelessWidget {
  const BackupRow({super.key, required this.backup});

  final BackupItem backup;

  @override
  Widget build(BuildContext context) {
    AppThemePalette palette = AppThemePalette.obsidianGold;
    try {
      final scope = context.dependOnInheritedWidgetOfExactType<AttendXScope>();
      if (scope?.notifier != null) {
        palette = scope!.notifier!.themePalette;
      }
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(CupertinoIcons.doc_text, color: palette.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(backup.name, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: palette.textPrimary)),
                Text(
                  backup.date,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Text(
            backup.size,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: palette.textMuted,
                ),
          ),
        ],
      ),
    );
  }
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
  String cancelLabel = 'Cancel',
  bool isDestructive = true,
}) async {
  AppThemePalette palette = AppThemePalette.obsidianGold;
  try {
    final scope = context.dependOnInheritedWidgetOfExactType<AttendXScope>();
    if (scope?.notifier != null) {
      palette = scope!.notifier!.themePalette;
    }
  } catch (_) {}

  final isDark = palette.isDark;

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: isDark ? palette.cardBorder : Colors.transparent),
      ),
      backgroundColor: isDark ? const Color(0xFF16130E) : Colors.white,
      surfaceTintColor: Colors.transparent,
      title: Text(
        title,
        style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
              color: palette.textPrimary,
              fontWeight: FontWeight.w800,
            ),
      ),
      content: Text(
        message,
        style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
              color: palette.textSecondary,
            ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          style: TextButton.styleFrom(
            foregroundColor: palette.textSecondary,
          ),
          child: Text(cancelLabel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: isDestructive ? AppPalette.red : (isDark ? palette.accent : AppPalette.green),
            foregroundColor: isDestructive ? Colors.white : (isDark ? Colors.black : Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

