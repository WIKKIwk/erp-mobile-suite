import 'package:flutter/foundation.dart';

class AppPreview {
  const AppPreview._();

  static const String _route = String.fromEnvironment(
    'APP_PREVIEW_ROUTE',
    defaultValue: '',
  );
  static const String _phone = String.fromEnvironment(
    'APP_PREVIEW_PHONE',
    defaultValue: '',
  );
  static const String _code = String.fromEnvironment(
    'APP_PREVIEW_CODE',
    defaultValue: '',
  );
  static const bool _forceEnabled = bool.fromEnvironment(
    'APP_FORCE_DEVICE_PREVIEW',
    defaultValue: false,
  );
  static const bool batchDispatchDemo = bool.fromEnvironment(
    'APP_PREVIEW_BATCH_DISPATCH_DEMO',
    defaultValue: false,
  );

  static bool get enabled {
    if (kReleaseMode) {
      return false;
    }

    if (_forceEnabled) {
      return true;
    }

    if (kIsWeb) {
      return false;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return true;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return false;
    }
  }

  static String? get initialRouteOverride {
    final route = _route.trim();
    if (route.isEmpty) {
      return null;
    }
    return route;
  }

  static bool get hasPreviewLoginCredentials =>
      _phone.trim().isNotEmpty && _code.trim().isNotEmpty;

  static String get previewPhone => _phone.trim();
  static String get previewCode => _code.trim();

  static bool get startDirectPreviewRoute =>
      batchDispatchDemo && initialRouteOverride != null;
}
