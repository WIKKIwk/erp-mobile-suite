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
    final route = ModalRoute.of(context);
    final canPop = navigator?.canPop() ?? false;
    final isCurrent = route?.isCurrent ?? true;
    final visible = canPop && !isCurrent;
    instance._syncVisibleFromBuild(visible);
    return visible;
  }

  static bool useNativeNavigationTitle(BuildContext context, String title) {
    return useNativeNavigationTitleWhenPossible(
      context,
      title,
      allowWithoutBackButton: false,
    );
  }

  static bool useNativeNavigationTitleWhenPossible(
    BuildContext context,
    String title, {
    required bool allowWithoutBackButton,
  }) {
    if (!_isSupportedPlatform) {
      return false;
    }
    final navigator = Navigator.maybeOf(context);
    final route = ModalRoute.of(context);
    final canPop = navigator?.canPop() ?? false;
    final isCurrent = route?.isCurrent ?? true;
    final visible = canPop && !isCurrent;
    final useNative = visible || allowWithoutBackButton;
    instance._syncVisibleFromBuild(visible);
    instance._syncNavigationBarVisibleFromBuild(useNative);
    instance
        ._syncThemeFromBuild(Theme.of(context).brightness == Brightness.dark);
    instance._syncTitleFromBuild(useNative ? title : null);
    return useNative;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _scheduleSync();
  }

  @override
  void didStartUserGesture(
      Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didStartUserGesture(route, previousRoute);
    if (!_initialized) {
      return;
    }
    unawaited(_setGestureActive(true));
  }

  @override
  void didStopUserGesture() {
    super.didStopUserGesture();
    if (!_initialized) {
      return;
    }
    unawaited(_setGestureActive(false));
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

  void _syncVisibleFromBuild(bool visible) {
    if (!_initialized) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_setVisible(visible));
    });
  }

  Future<void> _setVisible(bool visible) async {
    try {
      await _channel.invokeMethod('setBackButtonVisible', visible);
    } catch (_) {}
  }

  void _syncNavigationBarVisibleFromBuild(bool visible) {
    if (!_initialized) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_setNavigationBarVisible(visible));
    });
  }

  Future<void> _setNavigationBarVisible(bool visible) async {
    try {
      await _channel.invokeMethod('setNavigationBarVisible', visible);
    } catch (_) {}
  }

  void _syncTitleFromBuild(String? title) {
    if (!_initialized) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_setTitle(title));
    });
  }

  Future<void> _setTitle(String? title) async {
    try {
      await _channel.invokeMethod('setBackButtonTitle', title);
    } catch (_) {}
  }

  void _syncThemeFromBuild(bool isDark) {
    if (!_initialized) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_setTheme(isDark));
    });
  }

  Future<void> _setTheme(bool isDark) async {
    try {
      await _channel.invokeMethod('setBackButtonIsDark', isDark);
    } catch (_) {}
  }

  Future<void> _setGestureActive(bool active) async {
    try {
      await _channel.invokeMethod('setBackButtonGestureActive', active);
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
      case 'nativeBackButtonReady':
        _scheduleSync();
        return null;
      case 'nativeBackPressed':
        navigatorKey.currentState?.maybePop();
        return null;
      default:
        throw MissingPluginException('Unknown method ${call.method}');
    }
  }
}
