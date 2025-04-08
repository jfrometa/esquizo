// Library directive must come first
library web_utils_web;

import 'dart:html' as html;
import 'package:flutter/foundation.dart';

// A simpler implementation that uses dart:html directly instead of complex JS interop
class _WebImpl {
  static void reloadPage() {
    try {
      html.window.location.reload();
    } catch (e) {
      debugPrint('Error reloading page: $e');
    }
  }

  static void goToHomePage() {
    try {
      html.window.location.href = '/';
    } catch (e) {
      debugPrint('Error navigating to home: $e');
    }
  }

  static String getCurrentPath() {
    try {
      // Direct access to pathname via dart:html
      final pathname = html.window.location.pathname;
      debugPrint(
          '🌐 WebUtils raw path: "$pathname", full URL: "${html.window.location.href}"');

      // Return the path or '/' if empty
      return pathname?.isEmpty == true ? '/' : pathname ?? '/';
    } catch (e) {
      debugPrint('❌ Error getting current path: $e');
      return '/';
    }
  }

  // Get the full URL for debugging
  static String getFullUrl() {
    try {
      return html.window.location.href;
    } catch (e) {
      debugPrint('❌ Error getting full URL: $e');
      return 'error';
    }
  }
}
