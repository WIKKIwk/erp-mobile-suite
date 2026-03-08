import '../theme/app_motion.dart';
import 'package:flutter/material.dart';

class SmoothAppear extends StatelessWidget {
  const SmoothAppear({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 16),
    this.duration = AppMotion.medium,
  });

  final Widget child;
  final Duration delay;
  final Offset offset;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration + delay,
      curve: AppMotion.settle,
      builder: (context, value, animatedChild) {
        final double delayedValue = delay == Duration.zero
            ? value
            : ((value * (duration + delay).inMilliseconds) -
                        delay.inMilliseconds)
                    .clamp(0, duration.inMilliseconds)
                    .toDouble() /
                duration.inMilliseconds;

        return Opacity(
          opacity: delayedValue,
          child: Transform.translate(
            offset: Offset(
                offset.dx * (1 - delayedValue), offset.dy * (1 - delayedValue)),
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }
}

class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => pressed = true),
      onTapCancel: () => setState(() => pressed = false),
      onTapUp: (_) => setState(() => pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: pressed ? 0.985 : 1,
        duration: AppMotion.fast,
        curve: AppMotion.smooth,
        child: widget.child,
      ),
    );
  }
}
