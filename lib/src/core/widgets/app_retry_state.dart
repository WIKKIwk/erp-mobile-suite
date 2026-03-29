import '../localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppRetryState extends StatelessWidget {
  const AppRetryState({
    super.key,
    required this.onRetry,
    this.padding,
  });

  final Future<void> Function() onRetry;
  final EdgeInsetsGeometry? padding;

  static double retryIconSizeFor(Size screenSize) {
    return (screenSize.shortestSide * 0.29).clamp(104.0, 132.0).toDouble();
  }

  static double contentWidthFor(Size screenSize) {
    return (screenSize.width * 0.72).clamp(260.0, 320.0).toDouble();
  }

  static double topInsetFor(Size screenSize) {
    return (screenSize.height * 0.2).clamp(140.0, 190.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mediaQuery = MediaQuery.maybeOf(context);
    final screenSize = mediaQuery?.size ?? const Size(390, 844);
    final retryIconSize = retryIconSizeFor(screenSize);
    final contentWidth = contentWidthFor(screenSize);
    final resolvedPadding =
        padding ?? EdgeInsets.fromLTRB(20, topInsetFor(screenSize), 20, 24);

    return Padding(
      padding: resolvedPadding,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/server-disconnected.svg',
                width: retryIconSize,
                height: retryIconSize,
                colorFilter: ColorFilter.mode(
                  scheme.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: scheme.onSurfaceVariant,
                  textStyle: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
