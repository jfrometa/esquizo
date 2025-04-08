// Stub implementation for non-web platforms
// This file is only imported on non-web platforms

import 'package:flutter/foundation.dart';

// Implementation used on non-web platforms
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
