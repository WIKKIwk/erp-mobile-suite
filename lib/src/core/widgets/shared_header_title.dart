import 'dart:ui';

import '../theme/app_theme.dart';
import 'package:flutter/material.dart';

const String _sharedHeaderHeroTag = 'accord.shared-header-title';

class SharedHeaderTitle extends StatelessWidget {
  const SharedHeaderTitle({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final child = _SharedHeaderManifest(title: title);
    return Hero(
      tag: _sharedHeaderHeroTag,
      transitionOnUserGestures: true,
      flightShuttleBuilder: (
        flightContext,
        animation,
        flightDirection,
        fromHeroContext,
        toHeroContext,
      ) {
        final fromHero = (fromHeroContext.widget as Hero).child;
        final toHero = (toHeroContext.widget as Hero).child;
        if (fromHero is! _SharedHeaderManifest ||
            toHero is! _SharedHeaderManifest) {
          return toHero;
        }
        return _SharedHeaderFlight(
          animation: animation,
          from: fromHero,
          to: toHero,
        );
      },
      child: child,
    );
  }
}

class _SharedHeaderManifest extends StatelessWidget {
  const _SharedHeaderManifest({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.pageTitleStyle(context),
      ),
    );
  }
}

class _SharedHeaderFlight extends StatelessWidget {
  const _SharedHeaderFlight({
    required this.animation,
    required this.from,
    required this.to,
  });

  final Animation<double> animation;
  final _SharedHeaderManifest from;
  final _SharedHeaderManifest to;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = Curves.easeInOutCubicEmphasized.transform(
          animation.value.clamp(0.0, 1.0),
        );

        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              _AnimatedFlightTitle(
                title: from.title,
                shiftX: _lerpDouble(0, -18, t),
                opacity: _lerpDouble(1, 0, Curves.easeOut.transform(t)),
                blurSigma: _lerpDouble(0, 8, Curves.easeOut.transform(t)),
              ),
              _AnimatedFlightTitle(
                title: to.title,
                shiftX: _lerpDouble(18, 0, t),
                opacity: _lerpDouble(0, 1, Curves.easeIn.transform(t)),
                blurSigma: _lerpDouble(8, 0, Curves.easeOut.transform(t)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedFlightTitle extends StatelessWidget {
  const _AnimatedFlightTitle({
    required this.title,
    required this.shiftX,
    required this.opacity,
    required this.blurSigma,
  });

  final String title;
  final double shiftX;
  final double opacity;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    Widget child = Transform.translate(
      offset: Offset(shiftX, 0),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.pageTitleStyle(context),
      ),
    );

    if (blurSigma > 0.01) {
      child = ClipRect(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: child,
        ),
      );
    }

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: child,
    );
  }
}

class HeaderLeadingTransition extends StatelessWidget {
  const HeaderLeadingTransition({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final animation = route?.animation;
    if (animation == null) {
      return child;
    }

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, animatedChild) {
        final t = Curves.easeInOutCubicEmphasized.transform(
          animation.value.clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(_lerpDouble(-10, 0, t), 0),
            child: Transform.scale(
              alignment: Alignment.topLeft,
              scale: _lerpDouble(0.9, 1, t),
              child: animatedChild,
            ),
          ),
        );
      },
    );
  }
}

double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
