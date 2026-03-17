import 'dart:async';

import '../theme/app_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinCodeEditor extends StatefulWidget {
  const PinCodeEditor({
    super.key,
    required this.controller,
    required this.onAction,
    required this.actionLabel,
    required this.actionIcon,
    this.errorText,
    this.busy = false,
  });

  final TextEditingController controller;
  final VoidCallback onAction;
  final String actionLabel;
  final IconData actionIcon;
  final String? errorText;
  final bool busy;

  @override
  State<PinCodeEditor> createState() => _PinCodeEditorState();
}

class _PinCodeEditorState extends State<PinCodeEditor> {
  int _animateTick = 0;
  int? _insertingIndex;
  int? _deletingIndex;
  String _lastValue = '';

  @override
  void initState() {
    super.initState();
    _lastValue = widget.controller.text;
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant PinCodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      _lastValue = widget.controller.text;
      widget.controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() {
    final value = widget.controller.text;
    if (value == _lastValue) {
      return;
    }
    if (value.length > _lastValue.length && value.isNotEmpty) {
      _animateTick += 1;
      _insertingIndex = value.length - 1;
      _deletingIndex = null;
    } else if (value.length < _lastValue.length) {
      _animateTick += 1;
      _deletingIndex = _lastValue.length - 1;
      _insertingIndex = null;
      final deleteTick = _animateTick;
      Timer(const Duration(milliseconds: 320), () {
        if (!mounted || _animateTick != deleteTick) {
          return;
        }
        setState(() {
          _deletingIndex = null;
        });
      });
    }
    _lastValue = value;
    if (mounted) {
      setState(() {});
    }
  }

  bool get _canSubmit => widget.controller.text.length == 4 && !widget.busy;

  void _appendDigit(String digit) {
    if (widget.busy || widget.controller.text.length >= 4) {
      return;
    }
    HapticFeedback.selectionClick();
    final value = widget.controller.text + digit;
    widget.controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  void _removeDigit() {
    if (widget.busy || widget.controller.text.isEmpty) {
      return;
    }
    HapticFeedback.selectionClick();
    final value =
        widget.controller.text.substring(0, widget.controller.text.length - 1);
    widget.controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: _PinIndicatorRow(
            length: widget.controller.text.length,
            insertingIndex: _insertingIndex,
            deletingIndex: _deletingIndex,
            animateTick: _animateTick,
          ),
        ),
        if (widget.errorText != null &&
            widget.errorText!.trim().isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            widget.errorText!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.error,
            ),
          ),
        ],
        const SizedBox(height: 22),
        const Column(
          children: [
            _PinKeypadRow(digits: ['1', '2', '3']),
            SizedBox(height: 12),
            _PinKeypadRow(digits: ['4', '5', '6']),
            SizedBox(height: 12),
            _PinKeypadRow(digits: ['7', '8', '9']),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _PinActionButton(
              icon: Icons.backspace_outlined,
              onTap: _removeDigit,
              enabled: widget.controller.text.isNotEmpty && !widget.busy,
            ),
            _PinDigitButton(
              label: '0',
              onTap: () => _appendDigit('0'),
              enabled: !widget.busy,
            ),
            _PinActionButton(
              icon: widget.actionIcon,
              onTap: widget.onAction,
              enabled: _canSubmit,
              emphasized: true,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            widget.actionLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _PinIndicatorRow extends StatelessWidget {
  const _PinIndicatorRow({
    required this.length,
    required this.insertingIndex,
    required this.deletingIndex,
    required this.animateTick,
  });

  final int length;
  final int? insertingIndex;
  final int? deletingIndex;
  final int animateTick;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(4, (index) {
          final filled = index < length;
          final motion = filled && insertingIndex == index
              ? _PinGlyphMotion.insert
              : (!filled && deletingIndex == index)
                  ? _PinGlyphMotion.delete
                  : _PinGlyphMotion.none;
          return Padding(
            padding: EdgeInsets.only(right: index == 3 ? 0 : 12),
            child: _PinGlyph(
              filled: filled,
              motion: motion,
              animateTick: animateTick,
              variant: index,
            ),
          );
        }),
      ),
    );
  }
}

enum _PinGlyphMotion {
  none,
  insert,
  delete,
}

class _PinGlyph extends StatelessWidget {
  const _PinGlyph({
    required this.filled,
    required this.motion,
    required this.animateTick,
    required this.variant,
  });

  final bool filled;
  final _PinGlyphMotion motion;
  final int animateTick;
  final int variant;

  int get _shapeSeed => animateTick % 4;

  ShapeBorder _startShape() {
    switch (_shapeSeed) {
      case 0:
        return const StarBorder(
          points: 5,
          innerRadiusRatio: 0.42,
          pointRounding: 0.20,
          valleyRounding: 0.10,
          squash: 0.0,
        );
      case 1:
        return const StarBorder.polygon(
          sides: 3,
          pointRounding: 0.12,
        );
      case 2:
        return const StarBorder.polygon(
          sides: 5,
          pointRounding: 0.08,
        );
      default:
        return const StarBorder.polygon(
          sides: 6,
          pointRounding: 0.06,
        );
    }
  }

  ShapeBorder _midShape() {
    switch (_shapeSeed) {
      case 0:
        return const StarBorder.polygon(
          sides: 5,
          pointRounding: 0.46,
        );
      case 1:
        return const StarBorder.polygon(
          sides: 4,
          pointRounding: 0.32,
        );
      case 2:
        return const StarBorder.polygon(
          sides: 6,
          pointRounding: 0.28,
        );
      default:
        return const StarBorder.polygon(
          sides: 8,
          pointRounding: 0.26,
        );
    }
  }

  ShapeBorder _shapeAt(double t) {
    if (t < 0.34) {
      return _startShape();
    }
    if (t < 0.62) {
      final local = AppMotion.standardDecelerate.transform((t - 0.34) / 0.28);
      return ShapeBorder.lerp(_startShape(), _midShape(), local)!;
    }
    final local = AppMotion.standardDecelerate.transform((t - 0.62) / 0.38);
    return ShapeBorder.lerp(_midShape(), const CircleBorder(), local)!;
  }

  double _sizeAt(double t) {
    if (t < 0.34) {
      final local = Curves.easeOut.transform(t / 0.34);
      return 38.0 - (4.0 * local);
    }
    final local = AppMotion.standardDecelerate.transform((t - 0.34) / 0.66);
    return 34.0 - (14.0 * local);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (!filled && motion != _PinGlyphMotion.delete) {
      return const SizedBox(width: 36, height: 36);
    }

    if (motion == _PinGlyphMotion.none) {
      return const SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: _GlyphSurface(
            shape: CircleBorder(),
            color: null,
            size: 20,
          ),
        ),
      );
    }

    if (motion == _PinGlyphMotion.delete) {
      return TweenAnimationBuilder<double>(
        key: ValueKey<String>('glyph-delete-$variant-$animateTick'),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 340),
        curve: AppMotion.standardAccelerate,
        builder: (context, value, _) {
          final eased = AppMotion.standardAccelerate.transform(value);
          final size = 20.0 - (12.0 * eased);
          return SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: Opacity(
                opacity: 1 - eased,
                child: Transform.rotate(
                  angle: 0.18 * eased,
                  child: _GlyphSurface(
                    shape: ShapeBorder.lerp(
                      const CircleBorder(),
                      _midShape(),
                      eased,
                    )!,
                    color: scheme.primary,
                    size: size,
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey<String>('glyph-$variant-$animateTick'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1880),
      curve: AppMotion.standardDecelerate,
      builder: (context, value, _) {
        final eased = AppMotion.standardDecelerate.transform(value);
        final size = _sizeAt(value);
        return SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: Transform.rotate(
              angle: 0.34 * eased,
              child: Transform.scale(
                scale: 1.08 - (0.08 * eased),
                child: _GlyphSurface(
                  shape: _shapeAt(value),
                  color: scheme.primary,
                  size: size,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlyphSurface extends StatelessWidget {
  const _GlyphSurface({
    required this.shape,
    required this.color,
    this.size = 20,
  });

  final ShapeBorder shape;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: color ?? Theme.of(context).colorScheme.primary,
          shape: shape,
        ),
      ),
    );
  }
}

class _PinKeypadRow extends StatelessWidget {
  const _PinKeypadRow({
    required this.digits,
  });

  final List<String> digits;

  @override
  Widget build(BuildContext context) {
    final editor = context.findAncestorStateOfType<_PinCodeEditorState>()!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits
          .map(
            (digit) => _PinDigitButton(
              label: digit,
              onTap: () => editor._appendDigit(digit),
              enabled: !editor.widget.busy,
            ),
          )
          .toList(),
    );
  }
}

class _PinDigitButton extends StatefulWidget {
  const _PinDigitButton({
    required this.label,
    required this.onTap,
    required this.enabled,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  State<_PinDigitButton> createState() => _PinDigitButtonState();
}

class _PinDigitButtonState extends State<_PinDigitButton> {
  bool _pressed = false;
  Timer? _releaseTimer;

  @override
  void dispose() {
    _releaseTimer?.cancel();
    super.dispose();
  }

  void _press() {
    _releaseTimer?.cancel();
    if (!_pressed) {
      setState(() => _pressed = true);
    }
  }

  void _releaseSoon() {
    _releaseTimer?.cancel();
    _releaseTimer = Timer(const Duration(milliseconds: 120), () {
      if (mounted) {
        setState(() => _pressed = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final idleColor = scheme.surfaceContainerHigh.withValues(alpha: 0.78);
    final pressedColor = scheme.secondaryContainer.withValues(alpha: 0.78);
    final foreground = scheme.onSurface;
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => _press() : null,
      onTapUp: widget.enabled ? (_) => _releaseSoon() : null,
      onTapCancel: widget.enabled
          ? () {
              _releaseTimer?.cancel();
              setState(() => _pressed = false);
            }
          : null,
      onTap: widget.enabled
          ? () {
              widget.onTap();
              _releaseSoon();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          color: widget.enabled
              ? (_pressed ? pressedColor : idleColor)
              : idleColor.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(_pressed ? 20 : 999),
        ),
        alignment: Alignment.center,
        child: Text(
          widget.label,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: widget.enabled
                    ? foreground
                    : foreground.withValues(alpha: 0.35),
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }
}

class _PinActionButton extends StatefulWidget {
  const _PinActionButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
    this.emphasized = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final bool emphasized;

  @override
  State<_PinActionButton> createState() => _PinActionButtonState();
}

class _PinActionButtonState extends State<_PinActionButton> {
  bool _pressed = false;
  Timer? _releaseTimer;

  @override
  void dispose() {
    _releaseTimer?.cancel();
    super.dispose();
  }

  void _press() {
    _releaseTimer?.cancel();
    if (!_pressed) {
      setState(() => _pressed = true);
    }
  }

  void _releaseSoon() {
    _releaseTimer?.cancel();
    _releaseTimer = Timer(const Duration(milliseconds: 120), () {
      if (mounted) {
        setState(() => _pressed = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final idleColor = widget.emphasized
        ? scheme.primary.withValues(alpha: 0.82)
        : scheme.surfaceContainerHigh.withValues(alpha: 0.78);
    final pressedColor = widget.emphasized
        ? scheme.primary.withValues(alpha: 0.96)
        : scheme.secondaryContainer.withValues(alpha: 0.82);
    final foreground = widget.emphasized ? scheme.onPrimary : scheme.onSurface;
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => _press() : null,
      onTapUp: widget.enabled ? (_) => _releaseSoon() : null,
      onTapCancel: widget.enabled
          ? () {
              _releaseTimer?.cancel();
              setState(() => _pressed = false);
            }
          : null,
      onTap: widget.enabled
          ? () {
              widget.onTap();
              _releaseSoon();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          color: widget.enabled
              ? (_pressed ? pressedColor : idleColor)
              : idleColor.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(_pressed ? 20 : 999),
        ),
        alignment: Alignment.center,
        child: Icon(
          widget.icon,
          color:
              widget.enabled ? foreground : foreground.withValues(alpha: 0.35),
          size: 28,
        ),
      ),
    );
  }
}
