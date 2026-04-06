import 'package:flutter/material.dart';

class FlutterDockOverlayController extends ChangeNotifier {
  FlutterDockOverlayController._();

  static final FlutterDockOverlayController instance =
      FlutterDockOverlayController._();

  Widget? _dock;
  EdgeInsets _padding = const EdgeInsets.symmetric(horizontal: 20);
  Object? _owner;

  Widget? get dock => _dock;
  EdgeInsets get padding => _padding;

  void show({
    required Object owner,
    required Widget dock,
    required EdgeInsets padding,
  }) {
    final changed = _owner != owner || _dock.runtimeType != dock.runtimeType || _padding != padding;
    _owner = owner;
    _dock = dock;
    _padding = padding;
    if (changed) {
      notifyListeners();
    }
  }

  void clear(Object owner) {
    if (_owner != owner && _owner != null) {
      return;
    }
    if (_dock == null) {
      return;
    }
    _owner = null;
    _dock = null;
    _padding = const EdgeInsets.symmetric(horizontal: 20);
    notifyListeners();
  }
}

class FlutterDockOverlayHost extends StatelessWidget {
  const FlutterDockOverlayHost({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: child),
        AnimatedBuilder(
          animation: FlutterDockOverlayController.instance,
          builder: (context, _) {
            final dock = FlutterDockOverlayController.instance.dock;
            if (dock == null) {
              return const SizedBox.shrink();
            }
            return Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: FlutterDockOverlayController.instance.padding,
                  child: dock,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
