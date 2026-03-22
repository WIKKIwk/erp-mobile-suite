import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IOSLiquidDockItem {
  const IOSLiquidDockItem({
    required this.id,
    required this.active,
    this.primary = false,
    this.showBadge = false,
    this.allowLongPress = false,
  });

  final String id;
  final bool active;
  final bool primary;
  final bool showBadge;
  final bool allowLongPress;

  Map<String, Object> toMap() {
    return <String, Object>{
      'id': id,
      'active': active,
      'primary': primary,
      'showBadge': showBadge,
      'allowLongPress': allowLongPress,
    };
  }
}

class IOSLiquidDock extends StatefulWidget {
  const IOSLiquidDock({
    super.key,
    required this.items,
    required this.onTap,
    this.onLongPress,
    this.compact = true,
    this.tightToEdges = true,
  });

  final List<IOSLiquidDockItem> items;
  final ValueChanged<String> onTap;
  final ValueChanged<String>? onLongPress;
  final bool compact;
  final bool tightToEdges;

  @override
  State<IOSLiquidDock> createState() => _IOSLiquidDockState();
}

class _IOSLiquidDockState extends State<IOSLiquidDock> {
  static int _nextViewId = 0;
  late final int _viewId = _nextViewId++;
  MethodChannel? _channel;

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    final args =
        (call.arguments as Map<dynamic, dynamic>? ?? const <dynamic, dynamic>{});
    final id = '${args['id'] ?? ''}'.trim();
    if (id.isEmpty) {
      return;
    }
    switch (call.method) {
      case 'tap':
        widget.onTap(id);
        return;
      case 'longPress':
        widget.onLongPress?.call(id);
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: widget.compact ? 82 : 88,
      child: UiKitView(
        viewType: 'accord_liquid_dock',
        layoutDirection: TextDirection.ltr,
        creationParamsCodec: const StandardMessageCodec(),
        creationParams: <String, Object>{
          'channel': 'accord_liquid_dock/$_viewId',
          'compact': widget.compact,
          'tightToEdges': widget.tightToEdges,
          'items': widget.items.map((item) => item.toMap()).toList(),
        },
        onPlatformViewCreated: (_) {
          final channel = MethodChannel('accord_liquid_dock/$_viewId');
          _channel = channel;
          channel.setMethodCallHandler(_handleMethodCall);
        },
      ),
    );
  }
}
