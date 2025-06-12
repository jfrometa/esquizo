// Library directive must come first
library;

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
      final fullUrl = html.window.location.href;

      debugPrint('🌐 WebUtils raw path: "$pathname"');
      debugPrint('🌐 WebUtils full URL: "$fullUrl"');

      // Additional checks to ensure we're getting the right path
      if (pathname == null || pathname.isEmpty) {
        debugPrint('⚠️ WebUtils: pathname is null or empty, defaulting to "/"');
        return '/';
      }

      // Clean the pathname - remove trailing slashes except for root
      final cleanPath =
          pathname == '/' ? '/' : pathname.replaceAll(RegExp(r'/+$'), '');

      debugPrint('🌐 WebUtils cleaned path: "$cleanPath"');
      return cleanPath;
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
