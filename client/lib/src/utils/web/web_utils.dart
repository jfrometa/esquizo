// Conditionally include the web implementation
// This file will only be imported on web platforms
export 'web_utils_web.dart' if (dart.library.io) 'web_utils_stub.dart';
import 'package:flutter/foundation.dart';

// Platform agnostic API for web utilities
class WebUtils {
  // Reload the current page (for web)
  static void reloadPage() {
    if (kIsWeb) {
      _WebImpl.reloadPage();
    }
  }

  // Navigate to the home page (for web)
  static void goToHomePage() {
    if (kIsWeb) {
      _WebImpl.goToHomePage();
    }
  }

  // Get the current URL path (for web)
  static String getCurrentPath() {
    if (kIsWeb) {
      return _WebImpl.getCurrentPath();
    }
    return '/';
  }
}

// Implementation used on non-web platforms as a fallback
class _WebImpl {
  static void reloadPage() {
    // No-op on non-web platforms
    debugPrint('Reload page called on non-web platform');
  }

  static void goToHomePage() {
    // No-op on non-web platforms
    debugPrint('Go to home page called on non-web platform');
  }

  static String getCurrentPath() {
    // Return default path on non-web platforms
    return '/';
  }
}
