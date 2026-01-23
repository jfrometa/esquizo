// Business slug validation utilities
// Centralized validation logic for business slugs in routing

/// List of system routes that cannot be used as business slugs
const Set<String> _systemRoutes = {
  // Auth/system routes
  'admin',
  'signin',
  'signup',
  'onboarding',
  'error',
  'startup',
  'business-setup',
  'admin-setup',
  'authenticated-profile',
  'debug',

  // Default business routes (when no slug is present)
  'menu',
  'carrito',
  'cart',
  'cuenta',
  'ordenes',
  'catering-menu',
  'catering-quote',
  'subscripciones',
  'catering',
  'populares',
  'categorias',
  'platos',
  'completar-orden',
  'meal-plans',

  // Admin panel routes
  'dashboard',
  'products',
  'orders',
  'settings',
  'payments',
  'staff',
  'analytics',
  'tables',
};

/// Validates and sanitizes business slugs for routing
class BusinessSlugValidator {
  const BusinessSlugValidator._();

  /// Minimum length for a valid business slug
  static const int minLength = 2;

  /// Maximum length for a valid business slug
  static const int maxLength = 50;

  /// Pattern for valid slug characters (lowercase letters, numbers, hyphens)
  static final RegExp _validPattern = RegExp(r'^[a-z0-9-]+$');

  /// Check if a string is a valid business slug
  static bool isValid(String? slug) {
    if (slug == null || slug.isEmpty) return false;
    if (slug.length < minLength || slug.length > maxLength) return false;

    // Check for invalid characters
    if (slug.contains(' ') || slug.contains('?') || slug.contains('#')) {
      return false;
    }

    // Check for invalid hyphen placement
    if (slug.startsWith('-') || slug.endsWith('-') || slug.contains('--')) {
      return false;
    }

    // Must match valid pattern
    if (!_validPattern.hasMatch(slug)) return false;

    // Cannot be a system route
    if (isSystemRoute(slug)) return false;

    return true;
  }

  /// Check if a segment is a system route
  static bool isSystemRoute(String segment) {
    return _systemRoutes.contains(segment.toLowerCase());
  }

  /// Sanitize user input into a valid slug format
  /// Returns null if the input cannot be sanitized
  static String? sanitize(String? input) {
    if (input == null || input.isEmpty) return null;

    // Convert to lowercase and trim
    String slug = input.toLowerCase().trim();

    // Replace spaces and underscores with hyphens
    slug = slug.replaceAll(RegExp(r'[\s_]+'), '-');

    // Remove invalid characters
    slug = slug.replaceAll(RegExp(r'[^a-z0-9-]'), '');

    // Collapse multiple hyphens
    slug = slug.replaceAll(RegExp(r'-+'), '-');

    // Remove leading/trailing hyphens
    slug = slug.replaceAll(RegExp(r'^-+|-+$'), '');

    // Check length constraints
    if (slug.length < minLength) return null;
    if (slug.length > maxLength) {
      slug = slug.substring(0, maxLength);
      // Ensure we don't end with a hyphen after truncation
      slug = slug.replaceAll(RegExp(r'-+$'), '');
    }

    // Final validation
    return isValid(slug) ? slug : null;
  }

  /// Extract business slug from a URL path
  /// Returns null if path doesn't contain a valid business slug
  static String? extractFromPath(String path) {
    if (!path.startsWith('/')) return null;

    // Remove leading slash and split
    final segments = path.substring(1).split('/');
    if (segments.isEmpty || segments.first.isEmpty) return null;

    final firstSegment = segments.first;

    // Check if it's a valid business slug (not a system route)
    return isValid(firstSegment) ? firstSegment : null;
  }

  /// Get all system routes (for debugging/admin purposes)
  static Set<String> get systemRoutes => Set.unmodifiable(_systemRoutes);
}
