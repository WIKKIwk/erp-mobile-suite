import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeBackButtonBridge extends NavigatorObserver {
  NativeBackButtonBridge._();

  static final NativeBackButtonBridge instance = NativeBackButtonBridge._();
  static const MethodChannel _channel = MethodChannel(
    'accord/native_back_button',
  );

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || !_isSupportedPlatform) {
      return;
    }
    _initialized = true;
    _channel.setMethodCallHandler(_handleMethodCall);
    _scheduleSync();
  }

  static bool get _isSupportedPlatform =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static bool shouldUseNativeBackButton(BuildContext context) {
    if (!_isSupportedPlatform) {
      return false;
    }
    final navigator = Navigator.maybeOf(context);
    return navigator?.canPop() ?? false;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _scheduleSync();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _scheduleSync();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _scheduleSync();
  }

  @override
  void didReplace({
    Route<dynamic>? newRoute,
    Route<dynamic>? oldRoute,
  }) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _scheduleSync();
  }

  Future<void> _sync() async {
    if (!_initialized) {
      return;
    }
    final navigator = navigatorKey.currentState;
    final visible = navigator?.canPop() ?? false;
    try {
      await _channel.invokeMethod('setBackButtonVisible', visible);
    } catch (_) {}
  }

  void _scheduleSync() {
    if (!_initialized) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_sync());
    });
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'nativeBackPressed':
        navigatorKey.currentState?.maybePop();
        return null;
      default:
        throw MissingPluginException('Unknown method ${call.method}');
    }
  }
}
