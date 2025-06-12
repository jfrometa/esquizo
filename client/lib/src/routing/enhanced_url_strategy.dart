import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'dart:developer' as dev;

/// An extension of the PathUrlStrategy that handles business slugs properly
class EnhancedPathUrlStrategy extends PathUrlStrategy {
  // Store the current business slug
  String? _currentBusinessSlug;

  // Get the current business slug
  String? getCurrentBusinessSlug() => _currentBusinessSlug;
  
  // Set the current business slug
  void setCurrentBusinessSlug(String? slug) {
    _currentBusinessSlug = slug;
    dev.log('🔄 Business slug set to: ${slug ?? "default"}', name: 'URLStrategy');
  }

  @override
  String getPath() {
    final pathname = html.window.location.pathname;
    
    // Extract business slug from the pathname
    final businessSlug = extractBusinessSlugFromPath(pathname ?? '/');
    
    // Store the business slug if found
    if (businessSlug != null && businessSlug != _currentBusinessSlug) {
      dev.log('🔄 Detected business slug in URL: $businessSlug', name: 'URLStrategy');
      setCurrentBusinessSlug(businessSlug);
      return pathname ?? '/'; // Return the full path with business context
    }
    
    return pathname ?? '/'; // Return the regular path (no business context)
  }

  /// Initialize the enhanced URL strategy for web
  static void initialize() {
    if (!kIsWeb) return;
    
    debugPrint('🌐 Initializing enhanced URL strategy for business routing');
    usePathUrlStrategy();
    debugPrint('✅ Enhanced URL strategy initialized');
  }


  /// Extract business slug from a path if present
  static String? extractBusinessSlugFromPath(String path) {
    if (path == '/' || path.isEmpty) {
      return null;
    }
    
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) {
      return null;
    }
    
    // Check if the first segment is a valid business slug
    // You would typically validate this against your database
    final potentialSlug = segments[0];
    // For now, we'll assume any non-empty segment could be a business slug
    // In a real implementation, you'd check if this is a valid business
    return potentialSlug;
  }

  String getBusinessBaseUrl() {
    final businessSlug = getCurrentBusinessSlug();
    if (businessSlug != null && businessSlug.isNotEmpty) {
      return '/$businessSlug';
    }
    return '';
  }

  String buildBusinessAwareRoute(String route, {String? forceBusinessSlug}) {
    final businessSlug = forceBusinessSlug ?? getCurrentBusinessSlug();
    
    // If no business slug or it's the default, return the route as is
    if (businessSlug == null || businessSlug.isEmpty) {
      return route;
    }
    
    // If the route already includes the business slug, return as is
    if (route.startsWith('/$businessSlug')) {
      return route;
    }
    
    // Add the business slug to the route
    final normalizedRoute = route.startsWith('/') ? route : '/$route';
    return businessSlug.isEmpty ? normalizedRoute : '/$businessSlug$normalizedRoute';
  }

  static String getInitialLocationWithBusinessContext() {
    final pathname = html.window.location.pathname ?? '/';
    final search = html.window.location.search ?? '';
    final hash = html.window.location.hash ?? '';
    
    // Extract business slug from the pathname
    final businessSlug = EnhancedPathUrlStrategy.extractBusinessSlugFromPath(pathname);
    
    // Store the business slug if found
    if (businessSlug != null) {
      dev.log('🏢 Initial business context detected: $businessSlug', name: 'URLStrategy');
      // Cannot call setCurrentBusinessSlug here because this is a static method.
      
      // Return the full path with business context
      return pathname + search + hash;
    }
    
    // Return the regular path (no business context)
    return pathname + search + hash;
  }

  bool isBusinessSpecificRoute() {
    return getCurrentBusinessSlug() != null;
  }

  String getCurrentRouteWithoutBusinessSlug() {
    final pathname = html.window.location.pathname ?? '/';
    final search = html.window.location.search ?? '';
    final hash = html.window.location.hash ?? '';
    
    final businessSlug = getCurrentBusinessSlug();
    
    if (businessSlug != null && businessSlug.isNotEmpty) {
      // Remove the business slug from the path
      if (pathname.startsWith('/$businessSlug')) {
        final pathWithoutSlug = pathname.substring(businessSlug.length + 1);
        return (pathWithoutSlug.isEmpty ? '/' : pathWithoutSlug) + search + hash;
      }
    }
    
    return pathname + search + hash;
  }
}

/// Configure the enhanced path strategy for the web app
void configureEnhancedPathStrategy() {
  setUrlStrategy(EnhancedPathUrlStrategy());
  dev.log('🌐 Enhanced URL strategy configured for business slug support', name: 'URLStrategy');
}
