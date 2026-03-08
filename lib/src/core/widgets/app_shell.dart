import '../theme/app_motion.dart';
import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions,
    this.bottom,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget>? actions;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000000), Color(0xFF070707)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: AppMotion.slow,
                            curve: AppMotion.settle,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 12 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(title,
                                style: theme.textTheme.headlineMedium),
                          ),
                          if (subtitle.trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 460),
                              curve: AppMotion.settle,
                              builder: (context, value, child) {
                                return Opacity(opacity: value, child: child);
                              },
                              child: Text(subtitle,
                                  style: theme.textTheme.bodyMedium),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (actions != null) ...actions!,
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: child,
                ),
              ),
              if (bottom != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: bottom,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppShellIconAction extends StatelessWidget {
  const AppShellIconAction({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.smooth,
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF0B0B0B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1D1D1D)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
