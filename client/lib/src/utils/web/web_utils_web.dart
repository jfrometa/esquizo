// Library directive must come first
library;


// Conditional import for web-specific functionality
import 'package:web/web.dart' as web;
import 'package:flutter/foundation.dart';

// A simpler implementation that uses package:web directly instead of complex JS interop
class _WebImpl {
  static void reloadPage() {
    try {
      web.window.location.reload();
    } catch (e) {
      debugPrint('Error reloading page: $e');
    }
  }

  static void goToHomePage() {
    try {
      web.window.location.href = '/';
    } catch (e) {
      debugPrint('Error navigating to home: $e');
    }
  }

  static String getCurrentPath() {
    try {
      // Direct access to pathname via package:web
      final pathname = web.window.location.pathname;
      final fullUrl = web.window.location.href;

      debugPrint('🌐 WebUtils raw path: "$pathname"');
      debugPrint('🌐 WebUtils full URL: "$fullUrl"');

      // Additional checks to ensure we're getting the right path
      if (pathname.isEmpty) {
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
      return web.window.location.href;
    } catch (e) {
      debugPrint('❌ Error getting full URL: $e');
      return 'error';
    }
  }
}
