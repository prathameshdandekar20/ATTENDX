import 'package:flutter/material.dart';
import '../../widgets/common.dart';

class SplashScreen extends StatelessWidget {
  static const route = '/splash';

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.92, end: 1.0),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) => Transform.scale(
                  scale: scale,
                  child: child,
                ),
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(36),
                     boxShadow: [
                       BoxShadow(
                         color: Colors.black.withValues(alpha: 0.16),
                         blurRadius: 36,
                         offset: const Offset(0, 18),
                       ),
                     ],
                  ),
                  child: ClipRRect(
                     borderRadius: BorderRadius.circular(36),
                     child: Image.asset(
                       'assets/logo.png',
                       fit: BoxFit.cover,
                     ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'AttendX',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Offline-first attendance for students',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color:
                          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.58),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
